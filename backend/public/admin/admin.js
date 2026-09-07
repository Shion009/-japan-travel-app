const $ = (id) => document.getElementById(id);

function apiBase() {
  const el = $("apiBase");
  const val = el ? el.value.trim().replace(/\/$/, "") : "";
  return val || window.location.origin;
}
function adminKey() {
  const el = $("adminKey");
  return el ? el.value.trim() : "changeme123";
}

let REGIONS = [];
let CATEGORIES = [];
let ALL_SPOTS = [];
let ALL_USERS = [];

// ================= Tab Navigation =================
function setupTabs() {
  const tabs = document.querySelectorAll(".nav-tab");
  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      tabs.forEach((t) => t.classList.remove("active"));
      document.querySelectorAll(".tab-content").forEach((c) => c.classList.remove("active"));

      tab.classList.add("active");
      const targetId = tab.dataset.tab;
      const targetContent = $(targetId);
      if (targetContent) targetContent.classList.add("active");

      // โหลดข้อมูลตามแท็บที่เปิด
      if (targetId === "usersTabContent") {
        loadUsers();
      } else if (targetId === "spotsTabContent") {
        loadSpots();
      }
    });
  });
}

// ================= Spot Management =================
async function loadMeta() {
  try {
    const [regionsRes, categoriesRes] = await Promise.all([
      fetch(`${apiBase()}/api/regions`).then((r) => r.json()),
      fetch(`${apiBase()}/api/categories`).then((r) => r.json()),
    ]);
    REGIONS = regionsRes || [];
    CATEGORIES = categoriesRes || [];

    $("region").innerHTML = REGIONS.map((r) => `<option value="${r.id}">${r.th}</option>`).join("");
    $("category").innerHTML = CATEGORIES.map((c) => `<option value="${c.id}">${c.th}</option>`).join("");
  } catch (err) {
    console.error("Failed to load metadata:", err);
  }
}

function regionLabel(id) {
  return REGIONS.find((r) => r.id === id)?.th || id;
}
function categoryLabel(id) {
  return CATEGORIES.find((c) => c.id === id)?.th || id;
}

async function loadSpots() {
  const q = $("searchBox").value.trim();
  const base = apiBase();
  let url = `${base}/api/spots`;
  if (q) url += `?search=${encodeURIComponent(q)}`;

  try {
    const res = await fetch(url);
    ALL_SPOTS = await res.json();
    renderTable();
  } catch (err) {
    console.error("Failed to load spots:", err);
  }
}

function renderTable() {
  const tbody = $("tbody");
  if (!ALL_SPOTS.length) {
    tbody.innerHTML = `<tr><td colspan="5" class="empty">ยังไม่มีข้อมูลสถานที่</td></tr>`;
    return;
  }
  tbody.innerHTML = ALL_SPOTS.map(
    (s) => `
    <tr>
      <td>${s.imageUrl ? `<img src="${s.imageUrl}" alt="" width="60" height="45" style="object-fit:cover;border-radius:4px;background:#333;" referrerpolicy="no-referrer" onerror="this.onerror=null;this.style.background='#444';this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2260%22 height=%2245%22><rect width=%2260%22 height=%2245%22 fill=%22%23555%22/><text x=%2230%22 y=%2227%22 font-size=%2210%22 fill=%22%23999%22 text-anchor=%22middle%22>No img</text></svg>'" />` : "<span style='color:#666'>-</span>"}</td>
      <td><strong>${s.name}</strong><br/><small style="color:#777">${s.nameJp}</small></td>
      <td><span class="badge">${regionLabel(s.region)}</span></td>
      <td>${categoryLabel(s.category)}</td>
      <td class="actions" style="text-align: right;">
        <button class="edit-btn" data-id="${s.id}">แก้ไข</button>
        <button class="del-btn" data-id="${s.id}">ลบ</button>
      </td>
    </tr>`
  ).join("");

  tbody.querySelectorAll(".edit-btn").forEach((btn) =>
    btn.addEventListener("click", () => fillForm(ALL_SPOTS.find((s) => String(s.id) === String(btn.dataset.id))))
  );
  tbody.querySelectorAll(".del-btn").forEach((btn) =>
    btn.addEventListener("click", () => deleteSpot(btn.dataset.id))
  );
}

function updateImagePreview() {
  const input = $("imageUrl");
  const wrap = $("imgPreviewWrap");
  const img = $("imgPreview");
  const txt = $("imgPreviewText");
  if (!input || !wrap || !img) return;

  let val = input.value.trim();
  if (!val) {
    wrap.style.display = "none";
    return;
  }

  // แปลง Google Drive อัตโนมัติถ้ามี
  const driveMatch = val.match(/drive\.google\.com\/file\/d\/([a-zA-Z0-9_-]+)/) ||
                     val.match(/drive\.google\.com\/open\?id=([a-zA-Z0-9_-]+)/);
  if (driveMatch) {
    val = `https://lh3.googleusercontent.com/d/${driveMatch[1]}`;
    if (txt) txt.textContent = "✓ ตรวจพบลิงก์ Google Drive: แปลงเป็นลิงก์ไฟล์รูปตรงให้อัตโนมัติ";
  } else if (txt) {
    txt.textContent = "✓ ตัวอย่างรูปภาพจาก URL";
  }

  img.src = val;
  wrap.style.display = "block";
}

function fillForm(spot) {
  if (!spot) return;
  $("formTitle").textContent = `แก้ไข: ${spot.name}`;
  $("spotId").value = spot.id;
  $("name").value = spot.name;
  $("nameJp").value = spot.nameJp;
  $("region").value = spot.region;
  $("category").value = spot.category;
  $("season").value = spot.season;
  $("blurb").value = spot.blurb;
  $("detail").value = spot.detail;
  $("highlight").value = spot.highlight;
  $("imageUrl").value = spot.imageUrl && !spot.imageUrl.includes("/uploads/") ? spot.imageUrl : "";
  $("imageFile").value = "";

  // ฟิลด์เพิ่มเติม
  $("openingHours").value = spot.openingHours || "";
  $("fee").value = spot.fee || "";
  $("access").value = spot.access || "";
  $("address").value = spot.address || "";
  $("recommendedDuration").value = spot.recommendedDuration || "";
  $("bestTime").value = spot.bestTime || "";
  $("rating").value = spot.rating || "";
  $("coordinates").value = spot.coordinates || "";
  $("tips").value = spot.tips || "";
  $("seasonalAdvice").value = spot.seasonalAdvice || "";

  updateImagePreview();

  $("submitBtn").textContent = "บันทึกการแก้ไข";
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function resetForm() {
  $("formTitle").textContent = "เพิ่มสถานที่ใหม่";
  $("spotForm").reset();
  $("spotId").value = "";
  $("submitBtn").textContent = "บันทึกสถานที่";
  $("formStatus").textContent = "";
  $("formStatus").className = "status";
  const wrap = $("imgPreviewWrap");
  if (wrap) wrap.style.display = "none";
}

async function deleteSpot(id) {
  if (!confirm("ยืนยันลบสถานที่นี้?")) return;
  const key = adminKey();
  const res = await fetch(`${apiBase()}/api/spots/${id}?x-admin-key=${encodeURIComponent(key)}`, {
    method: "DELETE",
    headers: { "x-admin-key": key },
  });
  if (res.ok) {
    loadSpots();
    loadDbStats();
  } else {
    const err = await res.json().catch(() => ({}));
    alert(err.error || "ลบไม่สำเร็จ");
  }
}

async function submitForm(e) {
  e.preventDefault();
  const id = $("spotId").value;
  const key = adminKey();
  const formData = new FormData();
  formData.append("name", $("name").value);
  formData.append("nameJp", $("nameJp").value);
  formData.append("region", $("region").value);
  formData.append("category", $("category").value);
  formData.append("season", $("season").value);
  formData.append("blurb", $("blurb").value);
  formData.append("detail", $("detail").value);
  formData.append("highlight", $("highlight").value);
  if ($("imageUrl").value) formData.append("imageUrl", $("imageUrl").value);
  if ($("imageFile").files[0]) formData.append("image", $("imageFile").files[0]);

  // ส่งฟิลด์เพิ่มเติม
  formData.append("openingHours", $("openingHours").value);
  formData.append("fee", $("fee").value);
  formData.append("access", $("access").value);
  formData.append("address", $("address").value);
  formData.append("recommendedDuration", $("recommendedDuration").value);
  formData.append("bestTime", $("bestTime").value);
  formData.append("rating", $("rating").value);
  formData.append("coordinates", $("coordinates").value);
  formData.append("tips", $("tips").value);
  formData.append("seasonalAdvice", $("seasonalAdvice").value);

  const url = id 
    ? `${apiBase()}/api/spots/${id}?x-admin-key=${encodeURIComponent(key)}` 
    : `${apiBase()}/api/spots?x-admin-key=${encodeURIComponent(key)}`;
  const method = id ? "PUT" : "POST";

  const statusEl = $("formStatus");
  statusEl.textContent = "กำลังบันทึก...";
  statusEl.className = "status";

  try {
    const res = await fetch(url, {
      method,
      headers: { "x-admin-key": key },
      body: formData,
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || "บันทึกไม่สำเร็จ");
    statusEl.textContent = "บันทึกสำเร็จ ✓";
    statusEl.className = "status ok";
    resetForm();
    loadSpots();
    loadDbStats();
  } catch (err) {
    statusEl.textContent = err.message;
    statusEl.className = "status err";
  }
}

// ================= User Management =================
async function loadUsers() {
  const base = apiBase();
  const q = $("userSearchBox") ? $("userSearchBox").value.trim() : "";
  const key = adminKey();

  let url = `${base}/api/admin/users?x-admin-key=${encodeURIComponent(key)}`;
  if (q) url += `&search=${encodeURIComponent(q)}`;

  try {
    const res = await fetch(url, {
      headers: { "x-admin-key": key },
    });

    if (res.status === 404) {
      throw new Error("ไม่พบ API endpoint /api/admin/users — กรุณารีสตาร์ทเซิร์ฟเวอร์ด้วยคำสั่ง: node server.js");
    }
    if (res.status === 401) {
      throw new Error("รหัส x-admin-key ไม่ถูกต้อง (ค่าเริ่มต้นคือ changeme123)");
    }
    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err.error || `เกิดข้อผิดพลาด (${res.status})`);
    }

    ALL_USERS = await res.json();
    renderUserTable();
  } catch (err) {
    console.error("Failed to load users:", err);
    $("userTbody").innerHTML = `<tr><td colspan="5" class="empty" style="color:var(--shu);font-weight:500;padding:24px;">⚠️ ${err.message}</td></tr>`;
  }
}

function formatDate(dateStr) {
  if (!dateStr) return "-";
  try {
    const d = new Date(dateStr);
    return d.toLocaleString("th-TH", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  } catch {
    return dateStr;
  }
}

function renderUserTable() {
  const tbody = $("userTbody");
  if (!ALL_USERS.length) {
    tbody.innerHTML = `<tr><td colspan="5" class="empty">ยังไม่มีข้อมูลผู้ใช้งาน</td></tr>`;
    return;
  }

  tbody.innerHTML = ALL_USERS.map((u) => {
    const initial = (u.username || "U").charAt(0).toUpperCase();
    return `
    <tr>
      <td><span class="badge">#${u.id}</span></td>
      <td>
        <div class="user-name-cell">
          <span class="user-avatar">${initial}</span>
          <strong>${u.username}</strong>
        </div>
      </td>
      <td><a href="mailto:${u.email}" style="color:inherit;text-decoration:none;">${u.email}</a></td>
      <td style="color:#777;font-size:12px;">${formatDate(u.created_at)}</td>
      <td class="actions" style="text-align: right;">
        <button class="edit-btn user-edit-btn" data-id="${u.id}">แก้ไข</button>
        <button class="del-btn user-del-btn" data-id="${u.id}">ลบ</button>
      </td>
    </tr>`;
  }).join("");

  tbody.querySelectorAll(".user-edit-btn").forEach((btn) =>
    btn.addEventListener("click", () => fillUserForm(ALL_USERS.find((u) => String(u.id) === String(btn.dataset.id))))
  );
  tbody.querySelectorAll(".user-del-btn").forEach((btn) =>
    btn.addEventListener("click", () => deleteUser(btn.dataset.id))
  );
}

function fillUserForm(user) {
  if (!user) return;
  $("userFormTitle").textContent = `แก้ไขผู้ใช้: ${user.username}`;
  $("userId").value = user.id;
  $("username").value = user.username;
  $("email").value = user.email;
  $("password").value = "";
  $("password").removeAttribute("required");
  $("passwordHint").style.display = "block";
  $("userSubmitBtn").textContent = "บันทึกการแก้ไขผู้ใช้";
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function resetUserForm() {
  $("userFormTitle").textContent = "เพิ่มผู้ใช้ใหม่";
  $("userForm").reset();
  $("userId").value = "";
  $("password").setAttribute("required", "required");
  $("passwordHint").style.display = "none";
  $("userSubmitBtn").textContent = "บันทึกผู้ใช้";
  $("userFormStatus").textContent = "";
  $("userFormStatus").className = "status";
}

async function deleteUser(id) {
  const user = ALL_USERS.find((u) => String(u.id) === String(id));
  const confirmMsg = user ? `ยืนยันการลบผู้ใช้ "${user.username}" (${user.email}) หรือไม่?` : "ยืนยันการลบผู้ใช้นี้?";
  if (!confirm(confirmMsg)) return;

  const key = adminKey();
  const url = `${apiBase()}/api/admin/users/${id}?x-admin-key=${encodeURIComponent(key)}`;

  try {
    const res = await fetch(url, {
      method: "DELETE",
      headers: { "x-admin-key": key },
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || "ลบไม่สำเร็จ");

    loadUsers();
    loadDbStats();
  } catch (err) {
    alert(err.message);
  }
}

async function submitUserForm(e) {
  e.preventDefault();
  const id = $("userId").value;
  const username = $("username").value.trim();
  const email = $("email").value.trim();
  const password = $("password").value;
  const key = adminKey();

  const payload = { username, email };
  if (password) {
    if (password.length < 6) {
      $("userFormStatus").textContent = "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
      $("userFormStatus").className = "status err";
      return;
    }
    payload.password = password;
  } else if (!id) {
    $("userFormStatus").textContent = "ต้องระบุรหัสผ่านสำหรับผู้ใช้ใหม่";
    $("userFormStatus").className = "status err";
    return;
  }

  const url = id 
    ? `${apiBase()}/api/admin/users/${id}?x-admin-key=${encodeURIComponent(key)}` 
    : `${apiBase()}/api/admin/users?x-admin-key=${encodeURIComponent(key)}`;
  const method = id ? "PUT" : "POST";

  const statusEl = $("userFormStatus");
  statusEl.textContent = "กำลังบันทึก...";
  statusEl.className = "status";

  try {
    const res = await fetch(url, {
      method,
      headers: {
        "Content-Type": "application/json",
        "x-admin-key": key,
      },
      body: JSON.stringify(payload),
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || "บันทึกไม่สำเร็จ");

    statusEl.textContent = id ? "แก้ไขข้อมูลผู้ใช้สำเร็จ ✓" : "เพิ่มผู้ใช้ใหม่สำเร็จ ✓";
    statusEl.className = "status ok";
    resetUserForm();
    loadUsers();
    loadDbStats();
  } catch (err) {
    statusEl.textContent = err.message;
    statusEl.className = "status err";
  }
}

// ================= DB & Top Bar =================
function updateDbLinks() {
  const base = apiBase();
  const key  = encodeURIComponent(adminKey());
  $("dbViewBtn").href = `${base}/api/db?x-admin-key=${key}`;
  $("dbDlBtn").href   = `${base}/api/db/download?x-admin-key=${key}`;
}

function updatePmaLink() {
  const url = $("pmaUrl").value.trim() || "http://localhost:8080/phpmyadmin";
  $("pmaBtn").href = url;
}

async function loadDbStats() {
  const btn = $("dbRefreshBtn");
  btn.textContent = "...";
  try {
    const base = apiBase();
    const key  = encodeURIComponent(adminKey());
    const res  = await fetch(`${base}/api/db?x-admin-key=${key}`);
    if (!res.ok) throw new Error("unauthorized");
    const data = await res.json();
    $("statSpots").textContent   = (data.spots   || []).length;
    $("statRegions").textContent = (data.regions || []).length;
    $("statCats").textContent    = (data.categories || []).length;
    $("statUsers").textContent   = (data.users   || []).length;
  } catch (e) {
    $("statSpots").textContent = $("statRegions").textContent = $("statCats").textContent = $("statUsers").textContent = "!";
  }
  btn.textContent = "↻";
}

// ================= Event Listeners =================
setupTabs();

$("spotForm").addEventListener("submit", submitForm);
$("resetBtn").addEventListener("click", resetForm);
$("refreshBtn").addEventListener("click", loadSpots);
$("searchBox").addEventListener("input", () => {
  clearTimeout(window.__searchDebounce);
  window.__searchDebounce = setTimeout(loadSpots, 300);
});

$("userForm").addEventListener("submit", submitUserForm);
$("userResetBtn").addEventListener("click", resetUserForm);
$("userRefreshBtn").addEventListener("click", loadUsers);
$("userSearchBox").addEventListener("input", () => {
  clearTimeout(window.__userSearchDebounce);
  window.__userSearchDebounce = setTimeout(loadUsers, 300);
});

$("apiBase").addEventListener("change", () => {
  updateDbLinks();
  loadMeta().then(loadSpots);
  loadDbStats();
});
$("adminKey").addEventListener("change", () => {
  updateDbLinks();
  loadDbStats();
  const activeTab = document.querySelector(".nav-tab.active");
  if (activeTab && activeTab.dataset.tab === "usersTabContent") {
    loadUsers();
  }
});
$("pmaUrl").addEventListener("input", updatePmaLink);
$("pmaUrl").addEventListener("change", updatePmaLink);
$("dbRefreshBtn").addEventListener("click", () => {
  loadDbStats();
  loadSpots();
  loadUsers();
});

// Initialize
updateDbLinks();
updatePmaLink();
loadDbStats();
loadMeta().then(loadSpots);
