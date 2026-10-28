// Editor screen: sends command lines to MonitorController and drives runs, traces and IN waits.
(() => {
    'use strict';

    const $ = id => document.getElementById(id);
    const token = document.querySelector('meta[name="csrf-token"]').content;
    const logEl = $('log');
    const form = $('command-form');
    const input = $('command');
    const message = $('message');
    const modeEl = $('mode');
    const speed = $('speed');
    const breakButton = $('break');
    const tickMs = 40;
    const maxLogRows = 2000;
    const breakKeys = new Set(['b', 'B', 'נ']); // נ is B on a Hebrew keyboard

    let state = JSON.parse($('initial-state').textContent);
    let paused = false;
    let continuation = null;
    let timer = 0;
    let busy = false;
    const history = [];
    let historyIndex = 0;
    let switches = Number(read('micro8085.switches') ?? 0) & 0xff;

    const hex = (value, digits) => value.toString(16).toUpperCase().padStart(digits, '0');

    function read(key) {
        try { return localStorage.getItem(key); } catch { return null; }
    }

    function write(key, value) {
        try { localStorage.setItem(key, value); } catch { /* storage unavailable */ }
    }

    async function post(action, body = {}) {
        busy = true;
        try {
            const response = await fetch(`/monitor/${action}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': token },
                body: JSON.stringify(body),
            });
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            return await response.json();
        } catch (error) {
            show(`Connection error: ${error.message}`, 'error');
            return null;
        } finally {
            busy = false;
        }
    }

    async function execute(command) {
        const response = await post('execute', { command });
        if (response) handle(response, true);
    }

    async function step(steps) {
        const response = await post('continue', { steps });
        if (response) handle(response, false);
    }

    async function send(action, body) {
        clearTimeout(timer);
        const response = await post(action, body);
        if (response) handle(response, false);
    }

    function handle(response, fromCommand) {
        if (response.cleared) logEl.replaceChildren();
        response.lines.forEach(appendLine);

        if (response.errorMessage) {
            show(response.errorMessage, 'error', true);
        } else if (fromCommand) {
            show('');
        }
        if (fromCommand) {
            input.value = response.prompt;
            input.setSelectionRange(input.value.length, input.value.length);
        }
        if (response.beep) beep();
        if (response.printText) print(response.printText);

        continuation = response.continuation;
        if (continuation) show('Press space to continue, other to end.', 'info');

        state = response.state;
        render();
        schedule();
    }

    function appendLine(line) {
        const row = document.createElement('div');
        row.className = `row ${line.kind}`;
        const left = document.createElement('span');
        const right = document.createElement('span');
        left.textContent = line.left;
        right.textContent = line.right;
        row.append(left, right);
        logEl.append(row);
        while (logEl.childElementCount > maxLogRows) logEl.firstElementChild.remove();
        logEl.scrollTop = logEl.scrollHeight;
    }

    function show(text, kind = 'info', withHelp = false) {
        message.className = `message ${kind}`;
        message.textContent = text;
        if (withHelp && text) {
            const link = document.createElement('a');
            link.href = '/Help/Errors';
            link.textContent = 'F3 explains';
            message.append(' - ', link);
        }
    }

    function schedule() {
        clearTimeout(timer);
        const status = state.status;
        const idle = status === 'idle';
        input.disabled = !idle;
        breakButton.disabled = idle;

        switch (status) {
            case 'running':
            case 'delaying':
                if (paused) {
                    modeEl.textContent = 'Paused';
                    show('Press any key to continue', 'info');
                } else if (status === 'delaying') {
                    modeEl.textContent = 'Hold';
                    show(`HOLD ${state.delayMs} ms - space pauses, B breaks`, 'info');
                    timer = setTimeout(() => step(stepsPerTick()), state.delayMs);
                } else {
                    modeEl.textContent = 'Running';
                    show('Running - space pauses, B breaks', 'info');
                    timer = setTimeout(() => step(stepsPerTick()), tickMs);
                }
                break;
            case 'tracing':
                modeEl.textContent = 'Trace';
                show(`Trace ${state.nextInstruction} - any key steps, B breaks`, 'info');
                break;
            case 'waitingForInput':
                modeEl.textContent = 'Input';
                show(state.waitingPort === 0
                    ? 'Enter number #00 -> toggle switches 1-8, Enter to continue, B breaks'
                    : 'Enter key in #FF: press a key, B breaks', 'info');
                break;
            default:
                paused = false;
                modeEl.textContent = 'Ready';
                input.focus();
                break;
        }
    }

    function stepsPerTick() {
        return Math.max(1, Math.round(Number(speed.value) * tickMs / 1000));
    }

    function render() {
        const s = state;
        $('flags').textContent = [s.sign ? 'S' : 's', s.zero ? 'Z' : 'z', s.parity ? 'P' : 'p', s.carry ? 'C' : 'c'].join(' ')
            + (s.auxCarry ? '  AC' : '  ac');
        const h2 = v => `h${hex(v, 2)}`;
        const h4 = v => `h${hex(v, 4)}`;
        $('registers').textContent = [
            `AC  - ${h2(s.a)} b${s.a.toString(2).padStart(8, '0')} d${String(s.a).padStart(4)}`,
            `B   - ${h2(s.b)}    C - ${h2(s.c)}    M - ${h2(s.memoryAtBC)}`,
            `D   - ${h2(s.d)}    E - ${h2(s.e)}    M - ${h2(s.memoryAtDE)}`,
            `H   - ${h2(s.h)}    L - ${h2(s.l)}    M - ${h2(s.memoryAtHL)}`,
            `SP  - ${h4(s.sp)}`,
            `PC  - ${h4(s.pc)}             M - ${h2(s.memoryAtPC)}`,
            `PSW - ${h4(s.psw)}`,
            `      ${s.nextInstruction}`,
        ].join('\n');
        $('keyboard').textContent = s.keyboard;
        renderBits($('leds'), s.leds, 'led');
        renderBits($('switches'), switches, 'switch');
        renderDigits(s.digits, s.digitPosition);
        document.body.classList.toggle('awaiting-switches', s.status === 'waitingForInput' && s.waitingPort === 0);
    }

    function renderBits(container, value, kind) {
        if (container.childElementCount === 0) {
            for (let i = 0; i < 8; i++) {
                const element = document.createElement(kind === 'switch' ? 'button' : 'span');
                element.className = kind;
                if (kind === 'switch') {
                    element.type = 'button';
                    element.textContent = String(i + 1);
                    element.title = `Switch ${i + 1} (key ${i + 1})`;
                    element.addEventListener('click', () => toggleSwitch(i));
                } else {
                    element.title = `Bit ${7 - i}`;
                }
                container.append(element);
            }
        }
        [...container.children].forEach((element, i) => {
            const on = (value >> (7 - i) & 1) === 1;
            element.classList.toggle('on', on);
            if (kind === 'switch') element.setAttribute('aria-pressed', String(on));
        });
    }

    function toggleSwitch(index) {
        switches ^= 1 << (7 - index);
        write('micro8085.switches', String(switches));
        renderBits($('switches'), switches, 'switch');
    }

    // Segment bits, active low: d c b a dp g f e (bit 7 to bit 0), as wired on the original board.
    const segments = {
        a: { bit: 4, points: '14,6 46,6 40,12 20,12' },
        b: { bit: 5, points: '48,8 48,46 42,42 42,14' },
        c: { bit: 6, points: '48,54 48,92 42,86 42,58' },
        d: { bit: 7, points: '14,94 46,94 40,88 20,88' },
        e: { bit: 0, points: '12,54 12,92 18,86 18,58' },
        f: { bit: 1, points: '12,8 12,46 18,42 18,14' },
        g: { bit: 2, points: '16,50 22,45 38,45 44,50 38,55 22,55' },
    };

    function renderDigits(digits, position) {
        const container = $('digits');
        if (container.childElementCount === 0) {
            const ns = 'http://www.w3.org/2000/svg';
            for (let i = 0; i < 6; i++) {
                const svg = document.createElementNS(ns, 'svg');
                svg.setAttribute('viewBox', '0 0 60 100');
                svg.classList.add('digit');
                for (const [name, segment] of Object.entries(segments)) {
                    const polygon = document.createElementNS(ns, 'polygon');
                    polygon.setAttribute('points', segment.points);
                    polygon.dataset.bit = segment.bit;
                    polygon.dataset.segment = name;
                    svg.append(polygon);
                }
                const dot = document.createElementNS(ns, 'circle');
                dot.setAttribute('cx', '54');
                dot.setAttribute('cy', '93');
                dot.setAttribute('r', '4');
                dot.dataset.bit = '3';
                svg.append(dot);
                container.append(svg);
            }
        }
        [...container.children].forEach((svg, i) => {
            svg.classList.toggle('current', i === position);
            for (const shape of svg.children) {
                shape.classList.toggle('lit', (digits[i] >> Number(shape.dataset.bit) & 1) === 0);
            }
        });
    }

    let audio;
    function beep() {
        try {
            audio ??= new AudioContext();
            const oscillator = audio.createOscillator();
            const gain = audio.createGain();
            oscillator.type = 'square';
            oscillator.frequency.value = 880;
            gain.gain.value = 0.05;
            oscillator.connect(gain).connect(audio.destination);
            oscillator.start();
            oscillator.stop(audio.currentTime + 0.12);
        } catch { /* audio unavailable */ }
    }

    function print(text) {
        $('printout').textContent = text;
        window.print();
    }

    form.addEventListener('submit', event => {
        event.preventDefault();
        if (state.status !== 'idle' || busy) return;
        const command = input.value;
        if (command.trim()) {
            history.push(command.trim());
            historyIndex = history.length;
        }
        execute(command);
    });

    input.addEventListener('keydown', event => {
        if (event.key === 'ArrowUp' && historyIndex > 0) {
            input.value = history[--historyIndex];
        } else if (event.key === 'ArrowDown' && historyIndex < history.length) {
            input.value = history[++historyIndex] ?? '';
        } else if (event.key === 'Escape') {
            input.value = '';
        } else {
            return;
        }
        event.preventDefault();
    });

    breakButton.addEventListener('click', () => send('break'));

    speed.value = read('micro8085.speed') ?? speed.value;
    speed.addEventListener('change', () => write('micro8085.speed', speed.value));

    document.addEventListener('keydown', event => {
        if (event.ctrlKey || event.metaKey || event.altKey || /^F\d+$/.test(event.key)) return;
        if (event.target === speed) return;

        if (continuation) {
            event.preventDefault();
            const next = continuation;
            continuation = null;
            show('');
            if (event.key === ' ') execute(next);
            return;
        }

        const status = state.status;
        if (status === 'idle' || busy && status !== 'running') return;
        if (['Shift', 'Control', 'Alt', 'Meta', 'CapsLock'].includes(event.key)) return;
        event.preventDefault();

        if (breakKeys.has(event.key)) {
            paused = false;
            send('break');
            return;
        }

        switch (status) {
            case 'running':
            case 'delaying':
                if (paused) {
                    paused = false;
                    schedule();
                } else if (event.key === ' ') {
                    paused = true;
                    schedule();
                }
                break;
            case 'tracing':
                step(1);
                break;
            case 'waitingForInput':
                if (state.waitingPort === 0) {
                    if (event.key >= '1' && event.key <= '8') toggleSwitch(Number(event.key) - 1);
                    else if (event.key === 'Enter') send('input', { value: switches });
                } else if (event.key.length === 1 || event.key === 'Enter') {
                    send('input', { value: event.key === 'Enter' ? 13 : event.key.charCodeAt(0) & 0xff });
                }
                break;
        }
    });

    render();
    schedule();
})();
