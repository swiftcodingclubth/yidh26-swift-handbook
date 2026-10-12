// แบบฝึกหัดลาก card ไปวางที่เครื่องมือ (.tool-sort)
// ใช้ Pointer Events จึงลากได้ทั้งเมาส์และนิ้วบน iPad
// แตะ card แล้วแตะเครื่องมือ หรือใช้ Tab + Enter ก็ได้
(function () {
  function setup(root) {
    const pool = root.querySelector(".tool-sort__pool");
    const cards = Array.from(root.querySelectorAll(".tool-sort__card"));
    const zones = Array.from(root.querySelectorAll(".tool-sort__zone"));
    const score = root.querySelector(".tool-sort__score");
    const feedback = root.querySelector(".tool-sort__feedback");
    let selected = null;

    function shuffle() {
      cards
        .map((card) => [Math.random(), card])
        .sort((a, b) => a[0] - b[0])
        .forEach(([, card]) => pool.appendChild(card));
    }

    function updateScore() {
      const done = root.querySelectorAll(".tool-sort__card.is-correct").length;
      score.textContent = `ถูก ${done}/${cards.length}`;
      root.classList.toggle("is-done", done === cards.length);
      if (done === cards.length) feedback.textContent = "ครบแล้ว เก่งมาก 🎉";
    }

    function select(card) {
      if (selected) selected.classList.remove("is-selected");
      selected = card && card !== selected ? card : null;
      if (selected) selected.classList.add("is-selected");
      root.classList.toggle("is-picking", !!selected);
    }

    function place(card, zone) {
      select(null);
      if (card.dataset.answer === zone.dataset.tool) {
        zone.querySelector(".tool-sort__drop").appendChild(card);
        card.classList.add("is-correct");
        card.disabled = true;
        flash(zone, "is-right");
        feedback.textContent = "✓ " + card.dataset.hint;
      } else {
        flash(zone, "is-wrong");
        flash(card, "is-wrong");
        feedback.textContent = `✗ "${card.textContent}" ไม่ใช่ ${zone.querySelector("strong").textContent} ลองใหม่`;
      }
      updateScore();
    }

    function flash(el, cls) {
      el.classList.remove(cls);
      void el.offsetWidth; // เริ่ม animation ใหม่ทุกครั้ง
      el.classList.add(cls);
      setTimeout(() => el.classList.remove(cls), 600);
    }

    function zoneAt(x, y) {
      const el = document.elementFromPoint(x, y);
      return el && el.closest(".tool-sort__zone");
    }

    // ลาก
    cards.forEach((card) => {
      card.addEventListener("pointerdown", (down) => {
        if (card.disabled || down.button > 0) return;
        const start = { x: down.clientX, y: down.clientY };
        const rect = card.getBoundingClientRect();
        let ghost = null;
        let over = null;
        card.setPointerCapture(down.pointerId);

        function move(e) {
          if (!ghost) {
            if (Math.hypot(e.clientX - start.x, e.clientY - start.y) < 6) return;
            ghost = card.cloneNode(true);
            ghost.classList.add("tool-sort__ghost");
            ghost.style.width = rect.width + "px";
            document.body.appendChild(ghost);
            card.classList.add("is-dragging");
            select(null);
          }
          ghost.style.left = e.clientX - (start.x - rect.left) + "px";
          ghost.style.top = e.clientY - (start.y - rect.top) + "px";
          const zone = zoneAt(e.clientX, e.clientY);
          if (zone !== over) {
            if (over) over.classList.remove("is-over");
            if (zone) zone.classList.add("is-over");
            over = zone;
          }
        }

        function up(e) {
          card.removeEventListener("pointermove", move);
          card.removeEventListener("pointerup", up);
          card.removeEventListener("pointercancel", up);
          if (!ghost) return; // ไม่ได้ลาก ปล่อยให้ click ทำงาน
          ghost.remove();
          card.classList.remove("is-dragging");
          if (over) over.classList.remove("is-over");
          const zone = e.type === "pointerup" && zoneAt(e.clientX, e.clientY);
          if (zone) place(card, zone);
          card.dataset.dragged = "1"; // กัน click ที่ตามมาหลังลาก
        }

        card.addEventListener("pointermove", move);
        card.addEventListener("pointerup", up);
        card.addEventListener("pointercancel", up);
      });

      // แตะหรือกด Enter เพื่อเลือก card
      card.addEventListener("click", () => {
        if (card.dataset.dragged) return delete card.dataset.dragged;
        select(card);
      });
    });

    // แตะหรือกด Enter ที่เครื่องมือ เพื่อวาง card ที่เลือกไว้
    zones.forEach((zone) => {
      const choose = () => selected && place(selected, zone);
      zone.addEventListener("click", choose);
      zone.addEventListener("keydown", (e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          choose();
        }
      });
    });

    root.querySelector(".tool-sort__reset").addEventListener("click", () => {
      cards.forEach((card) => {
        card.classList.remove("is-correct");
        card.disabled = false;
      });
      select(null);
      shuffle();
      feedback.textContent = "";
      updateScore();
    });

    shuffle();
    updateScore();
  }

  function init() {
    document.querySelectorAll(".tool-sort:not([data-ready])").forEach((root) => {
      root.dataset.ready = "1";
      setup(root);
    });
  }

  // รองรับ Material instant loading ถ้าเปิดภายหลัง
  if (window.document$) window.document$.subscribe(init);
  else document.addEventListener("DOMContentLoaded", init);
})();
