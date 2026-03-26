(() => {
  "use strict";
  const STORAGE_KEY = "cecyte_release_db_v1";
  const SIGNATURES = [
    { key: "biblioteca", label: "Biblioteca" },
    { key: "asesor", label: "Asesor" },
    { key: "enfermeria", label: "Enfermería" },
    { key: "control_escolar", label: "Control escolar" },
    { key: "prefectura", label: "Prefectura" },
    { key: "coord_academica", label: "Coordinación académica" }
  ];
  const STAFF_ROLE_LABEL = "Docente / Personal administrativo";
  const STUDENT_ROLE_LABEL = "Alumno";
  const appEl = document.getElementById("app");
  const $ = (sel) => appEl.querySelector(sel);
  function createEl(html) {
    const t = document.createElement("template");
    t.innerHTML = html.trim();
    return t.content.firstElementChild;
  }
  function normalizeInput(value) {
    return String(value ?? "").trim();
  }
  function showMessage(text, type = "error") {
    const msg = $("#formMessage");
    if (!msg) return;
    msg.textContent = text;
    msg.classList.remove("hidden", "error", "ok");
    if (type === "ok") msg.classList.add("ok");
    else msg.classList.add("error");
  }
  function hideMessage() {
    const msg = $("#formMessage");
    if (!msg) return;
    msg.textContent = "";
    msg.classList.add("hidden");
  }
  function loadDb() {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      const db = seedDb();
      localStorage.setItem(STORAGE_KEY, JSON.stringify(db));
      return db;
    }
    try {
      return JSON.parse(raw);
    } catch {
      const db = seedDb();
      localStorage.setItem(STORAGE_KEY, JSON.stringify(db));
      return db;
    }
  }
  function emptySignatures() {
    const obj = {};
    for (const s of SIGNATURES) obj[s.key] = false;
    return obj;
  }
  function seedDb() {
    const students = [
      {
        matricula: "20240001",
        nombre: "Alumno Uno",
        password: "1234",
        signatures: { biblioteca: false, asesor: false, enfermeria: false, control_escolar: false, prefectura: false, coord_academica: false }
      },
      {
        matricula: "20240002",
        nombre: "Alumno Dos",
        password: "1234",
        signatures: { biblioteca: true, asesor: false, enfermeria: false, control_escolar: false, prefectura: false, coord_academica: false }
      },
      {
        matricula: "20240003",
        nombre: "Alumno Tres",
        password: "1234",
        signatures: { biblioteca: true, asesor: true, enfermeria: false, control_escolar: false, prefectura: false, coord_academica: false }
      }
    ];
    const staff = [
      { employeeNumber: "1001", nombre: "Docente 1", password: "pass1" },
      { employeeNumber: "1002", nombre: "Administrativo 1", password: "pass2" }
    ];
    const studentsByMat = {};
    for (const st of students) studentsByMat[st.matricula] = st;
    const staffByEmp = {};
    for (const s of staff) staffByEmp[s.employeeNumber] = s;
    return {
      version: 1,
      students: studentsByMat,
      staff: staffByEmp
    };
  }
  let db = loadDb();
  function saveDb() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(db));
  }
  function studentHasAnyReleased(student) {
    return SIGNATURES.some((s) => Boolean(student.signatures[s.key]));
  }
  function releaseAllForStudent(student) {
    for (const s of SIGNATURES) student.signatures[s.key] = true;
    student.releasedAt = new Date().toISOString();
  }
  function isValidMatricula(matricula) {
    if (!matricula) return false;
    return Object.prototype.hasOwnProperty.call(db.students, matricula);
  }
  function isValidEmployeeNumber(employeeNumber) {
    if (!employeeNumber) return false;
    return Object.prototype.hasOwnProperty.call(db.staff, employeeNumber);
  }
  function renderBaseShell(bodyHtml) {
    appEl.innerHTML = `
      <article class="card">
        ${bodyHtml}
      </article>
    `;
  }
  function renderRoleSelect() {
    renderBaseShell(`
      <div class="hero">
        <h1>Liberación semestral (CECyTE)</h1>
        <p>Selecciona tu perfil para continuar.</p>
      </div>
      <div class="actions">
        <button class="btn" data-action="go-student-login" type="button">Soy estudiante</button>
        <button class="btn secondary" data-action="go-staff-login" type="button">${STAFF_ROLE_LABEL}</button>
      </div>
      <div class="demo">
        <details>
          <summary>Datos de demostración</summary>
          <div style="margin-top:8px;">
            <div><span class="kbd">Matrícula</span> <span class="kbd">20240001</span> y contraseña <span class="kbd">1234</span></div>
            <div style="margin-top:4px;"><span class="kbd">Personal</span> <span class="kbd">1001</span> contraseña <span class="kbd">pass1</span></div>
            <div style="margin-top:4px;"><span class="kbd">Personal</span> <span class="kbd">1002</span> contraseña <span class="kbd">pass2</span></div>
          </div>
        </details>
      </div>
    `);
  }
  function renderStudentLogin() {
    renderBaseShell(`
      <div class="hero">
        <h1>Inicio de sesión</h1>
        <p>Acceso como estudiante.</p>
      </div>
      <form id="studentLoginForm" class="grid two" style="margin-top:12px;">
        <div class="field">
          <div class="label">Matrícula</div>
          <input id="studentMatricula" inputmode="numeric" autocomplete="username" placeholder="Ej. 20240001" />
        </div>
        <div class="field">
          <div class="label">Contraseña</div>
          <input id="studentPassword" type="password" autocomplete="current-password" placeholder="Contraseña" />
        </div>
        <div style="grid-column:1 / -1;">
          <div id="formMessage" class="msg hidden" role="alert"></div>
          <div class="actions" style="margin-top:10px;">
            <button class="btn" type="submit">Entrar</button>
            <button class="btn secondary" data-action="back-to-role" type="button">Volver</button>
          </div>
        </div>
      </form>
    `);
    hideMessage();
  }
  function renderStaffLogin() {
    renderBaseShell(`
      <div class="hero">
        <h1>Inicio de sesión</h1>
        <p>Acceso como ${STAFF_ROLE_LABEL}.</p>
      </div>
      <form id="staffLoginForm" class="grid two" style="margin-top:12px;">
        <div class="field">
          <div class="label">Número de empleado</div>
          <input id="staffEmployeeNumber" inputmode="numeric" autocomplete="username" placeholder="Ej. 1001" />
        </div>
        <div class="field">
          <div class="label">Contraseña</div>
          <input id="staffPassword" type="password" autocomplete="current-password" placeholder="Contraseña" />
        </div>
        <div style="grid-column:1 / -1;">
          <div id="formMessage" class="msg hidden" role="alert"></div>
          <div class="actions" style="margin-top:10px;">
            <button class="btn" type="submit">Entrar</button>
            <button class="btn secondary" data-action="back-to-role" type="button">Volver</button>
          </div>
        </div>
      </form>
    `);
    hideMessage();
  }
  function renderStaffRelease(staff) {
    const name = staff?.nombre ?? "Personal";
    renderBaseShell(`
      <div class="hero">
        <h1>Liberación de horas</h1>
        <p>Hola, <strong>${escapeHtml(name)}</strong>. Ingresa la matrícula del alumno a liberar.</p>
      </div>
      <form id="releaseForm" style="margin-top:12px;" class="grid two">
        <div class="field">
          <div class="label">Matrícula del alumno</div>
          <input id="releaseMatricula" inputmode="numeric" autocomplete="off" placeholder="Ej. 20240002" />
        </div>
        <div class="field">
          <div class="label">Acción</div>
          <button class="btn" data-action="liberar" type="button" style="height:46px; display:flex; align-items:center; justify-content:center;">Liberar</button>
        </div>
        <div style="grid-column:1 / -1;">
          <div id="formMessage" class="msg hidden" role="alert"></div>
          <div class="actions" style="margin-top:10px;">
            <button class="btn secondary" data-action="back-to-role" type="button">Inicio</button>
          </div>
        </div>
      </form>
      <div class="demo">
        <strong>Cómo funciona:</strong> al liberar, se marcan las 6 firmas como liberadas para esa matrícula.
      </div>
    `);
    hideMessage();
    const btn = $('[data-action="liberar"]');
    btn.addEventListener("click", () => {
      const matricula = normalizeInput($("#releaseMatricula").value);
      const msg = $("#formMessage");
      if (!msg) return;
      if (!isValidMatricula(matricula)) {
        showMessage("matrícula incorrecta", "error");
        return;
      }
      const student = db.students[matricula];
      releaseAllForStudent(student);
      saveDb();
      showMessage("Alumno liberado correctamente.", "ok");
      // Regreso al inicio de captura para otra matrícula.
      const input = $("#releaseMatricula");
      input.value = "";
      input.focus();
    });
  }
  function renderStudentSignatures(student) {
    const releasedCount = SIGNATURES.filter((s) => student.signatures[s.key]).length;
    renderBaseShell(`
      <div class="hero">
        <h1>Firmas liberadas</h1>
        <p>${escapeHtml(student.nombre)} · <span class="kbd">${releasedCount}/6 liberadas</span></p>
      </div>
      <div class="sig-grid" aria-label="Firmas liberadas">
        ${SIGNATURES.map((s) => {
          const released = Boolean(student.signatures[s.key]);
          const badge = released ? "Liberado" : "Pendiente";
          const badgeClass = released ? "ok" : "pending";
          return `
            <div class="sig" role="group" aria-label="${escapeHtml(s.label)}">
              <div class="sig-top">
                <div class="sig-name">${escapeHtml(s.label)}</div>
                <div class="badge ${badgeClass}">${badge}</div>
              </div>
              <div class="status">
                ${released ? "Listo para tu liberación semestral." : "Aún no se encuentra liberada."}
              </div>
            </div>
          `;
        }).join("")}
      </div>
      <div class="actions" style="margin-top:14px;">
        <button class="btn secondary" data-action="back-to-role" type="button">Inicio</button>
      </div>
    `);
  }
  function escapeHtml(str) {
    return String(str ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");
  }
  function attachGlobalHandlers() {
    appEl.addEventListener("click", (e) => {
      const t = e.target.closest("[data-action]");
      if (!t) return;
      const action = t.getAttribute("data-action");
      if (action === "back-to-role") {
        renderRoleSelect();
      } else if (action === "go-student-login") {
        renderStudentLogin();
      } else if (action === "go-staff-login") {
        renderStaffLogin();
      }
    });
  }
  function attachFormHandlers() {
    const studentForm = $("#studentLoginForm");
    if (studentForm) {
      studentForm.addEventListener("submit", (ev) => {
        ev.preventDefault();
        hideMessage();
        const matricula = normalizeInput($("#studentMatricula").value);
        const password = normalizeInput($("#studentPassword").value);
        if (!matricula || !isValidMatricula(matricula)) {
          showMessage("matrícula incorrecta", "error");
          return;
        }
        if (!password) {
          showMessage("contraseña incorrecta", "error");
          return;
        }
        const student = db.students[matricula];
        if (student.password !== password) {
          showMessage("contraseña incorrecta", "error");
          return;
        }
        renderStudentSignatures(student);
      });
    }
    const staffForm = $("#staffLoginForm");
    if (staffForm) {
      staffForm.addEventListener("submit", (ev) => {
        ev.preventDefault();
        hideMessage();
        const employeeNumber = normalizeInput($("#staffEmployeeNumber").value);
        const password = normalizeInput($("#staffPassword").value);
        if (!employeeNumber || !isValidEmployeeNumber(employeeNumber)) {
          showMessage("número de empleado incorrecto", "error");
          return;
        }
        if (!password) {
          showMessage("contraseña incorrecta", "error");
          return;
        }
        const staff = db.staff[employeeNumber];
        if (staff.password !== password) {
          showMessage("contraseña incorrecta", "error");
          return;
        }
        renderStaffRelease(staff);
      });
    }
  }
  function reattachScreens() {
    attachFormHandlers();
  }
  function renderInitial() {
    renderRoleSelect();
    attachGlobalHandlers();
  }
  // Re-attach handlers after each render that uses forms.
  const originalRenderRoleSelect = renderRoleSelect;
  const originalRenderStudentLogin = renderStudentLogin;
  const originalRenderStaffLogin = renderStaffLogin;
  const originalRenderStaffRelease = renderStaffRelease;
  const originalRenderStudentSignatures = renderStudentSignatures;
  // Wrap renderers to attach form handlers after update.
  renderRoleSelect = () => {
    originalRenderRoleSelect();
    reattachScreens();
  };
  renderStudentLogin = () => {
    originalRenderStudentLogin();
    reattachScreens();
  };
  renderStaffLogin = () => {
    originalRenderStaffLogin();
    reattachScreens();
  };
  renderStaffRelease = (staff) => {
    originalRenderStaffRelease(staff);
  };
  renderStudentSignatures = (student) => {
    originalRenderStudentSignatures(student);
  };
  renderInitial();
})();
