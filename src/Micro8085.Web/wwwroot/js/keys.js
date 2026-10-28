// Function keys from the original status line: F1 orders, F3 errors, F5 operator, F7 exit, F9 input/output.
document.addEventListener('keydown', event => {
    const link = document.querySelector(`.keys a[data-key="${event.key}"]`);
    if (link) {
        event.preventDefault();
        link.click();
        return;
    }
    // Esc leaves a menu window, as F7 did; on the editor it clears the line instead.
    const editable = event.target instanceof HTMLInputElement || event.target instanceof HTMLSelectElement;
    if (event.key === 'Escape' && !document.getElementById('command') && !editable) {
        document.querySelector('.keys a[data-key="F7"]').click();
    }
});
