const wrap = document.getElementById('taser-wrap');
const rack = document.getElementById('taser-rack');
let max = 2;

function render(count){
    rack.innerHTML = '';
    for(let i=0; i<max; i++) {
        const el = document.createElement('div');
        el.className = 'slot' + (i < count ? ' on' : '');
        rack.appendChild(el);
    }
}

window.addEventListener('message', e => {
    const d = e.data || {};
    if(d.action === 'taser:toggle') {
        if(typeof d.state === 'boolean') // forced state from boolean
            wrap.classList.toggle('hidden', !d.state);
        else // toggle
            wrap.classList.toggle('hidden');
    }
    if(d.action === 'taser:update') {
        render(Math.max(0, Math.min(d.count || 0, max)));
    }
});

// get the max cartridges from lua on load
async function bootstrapFromLua(){
    const res = await fetch(`https://${GetParentResourceName()}/taser:setMax`, {
        method:'POST',
        headers:{ 'Content-Type':'application/json' },
        body: JSON.stringify({})
    });
    const data = await res.json();
    max = data.max;

    render(max);
}

// get max cartridges then render
bootstrapFromLua();