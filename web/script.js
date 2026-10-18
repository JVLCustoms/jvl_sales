'use strict';

/* JVL Sales - NUI. The total is a preview; the server pays with the config prices. */

const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'jvl_sales';
const $ = (selector) => document.querySelector(selector);

const state = { texts: {}, data: null, image: '', cart: {}, busy: false };

const post = (endpoint, body) => fetch(`https://${resource}/${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(body || {}),
}).then((r) => r.json()).catch(() => ({ ok: false }));

const t = (key, ...args) => args.reduce((text, arg) => text.replace('%s', arg), state.texts[key] || key);
const money = (value) => `$${Math.floor(Number(value) || 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')}`;

function el(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
}

function picture(item) {
    const box = el('div', 'imagen');
    const icon = el('i');
    icon.className = 'fa-solid fa-box';
    if (!state.image) return box.appendChild(icon) && box;
    const img = document.createElement('img');
    img.src = state.image.replace('%s', item);
    img.onerror = () => img.replaceWith(icon);
    box.append(img);
    return box;
}

function total() {
    return state.data.items.reduce((sum, i) => sum + (state.cart[i.item] || 0) * i.price, 0);
}

function updateTotal() {
    $('#total').textContent = money(total());
    $('#vender').disabled = total() <= 0 || state.busy;
}

function setAmount(entry, value, input, row) {
    const amount = Math.max(0, Math.min(entry.have, Math.floor(Number(value) || 0)));
    state.cart[entry.item] = amount;
    input.value = amount;
    row.classList.toggle('elegido', amount > 0);
    updateTotal();
}

function render() {
    const items = state.data.items;
    $('#comprador').textContent = state.data.label;
    $('#cuenta').textContent = t(state.data.account === 'bank' ? 'bank' : 'cash');
    if (!items.some((i) => i.have > 0)) $('#items').replaceChildren(el('div', 'vacio', t('none')));
    else {
        // Items the player has first
        const sorted = [...items].sort((a, b) => (b.have > 0) - (a.have > 0));
        $('#items').replaceChildren(...sorted.map((entry) => {
            const row = el('div', `item${entry.have > 0 ? '' : ' sin'}`);
            const info = el('div');
            const data = el('div', 'datos');
            data.append(el('em', null, `${money(entry.price)} ${t('each')}`), document.createTextNode(` · ${t('have', entry.have)}`));
            info.append(el('b', null, entry.label), data);
            const controls = el('div', 'cantidad');
            const minus = el('button', null, '−');
            const input = el('input');
            input.type = 'number';
            input.min = 0;
            input.max = entry.have;
            const plus = el('button', null, '+');
            const all = el('button', 'todo', t('all'));
            [minus, input, plus, all].forEach((node) => { node.disabled = entry.have <= 0; });
            minus.onclick = () => setAmount(entry, (state.cart[entry.item] || 0) - 1, input, row);
            plus.onclick = () => setAmount(entry, (state.cart[entry.item] || 0) + 1, input, row);
            all.onclick = () => setAmount(entry, entry.have, input, row);
            input.oninput = () => setAmount(entry, input.value, input, row);
            controls.append(minus, input, plus, all);
            row.append(picture(entry.item), info, controls);
            setAmount(entry, state.cart[entry.item] || 0, input, row);
            return row;
        }));
    }
    updateTotal();
}

function close() {
    $('#panel').classList.add('oculto');
    post('close');
}

window.addEventListener('message', ({ data: msg }) => {
    if (msg.action === 'open') {
        state.texts = msg.texts || {};
        state.image = msg.image || '';
        state.data = msg.data;
        state.cart = {};
        $('#titulo').textContent = t('title');
        $('#total-texto').textContent = t('total');
        $('#vender').textContent = t('sell');
        $('#pie').textContent = t('close');
        $('#version').textContent = msg.version ? `v${msg.version}` : '';
        // Header logo from config; broken or empty URL falls back to the icon
        const logo = $('#logo');
        $('#icono').innerHTML = `<i class="${msg.icon || 'fa-solid fa-recycle'}"></i>`;
        logo.classList.remove('con-imagen');
        if (msg.logo) {
            const img = logo.querySelector('img');
            img.onerror = () => logo.classList.remove('con-imagen');
            img.src = msg.logo;
            logo.classList.add('con-imagen');
        }
        render();
        $('#panel').classList.remove('oculto');
    } else if (msg.action === 'update') {
        state.data = msg.data;
        state.cart = {};
        render();
    }
});

$('#vender').onclick = async () => {
    if (state.busy || total() <= 0) return;
    state.busy = true;
    updateTotal();
    await post('sell', { cart: state.cart });
    state.busy = false;
    updateTotal();
};
$('#cerrar').onclick = close;
document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape' && !$('#panel').classList.contains('oculto')) close();
});
