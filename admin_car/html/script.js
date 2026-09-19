// ============================================================
// ADMIN CAR - GARA XE CÁ NHÂN CLIENT NUI JAVASCRIPT
// ============================================================

let allCars = [];
let editingCarId = null;

const app = document.getElementById('app');
const carsGrid = document.getElementById('carsGrid');
const emptyState = document.getElementById('emptyState');
const noSearchResult = document.getElementById('noSearchResult');
const searchInput = document.getElementById('searchInput');
const clearSearch = document.getElementById('clearSearch');

const totalCarsCount = document.getElementById('totalCarsCount');
const spawnedCarsCount = document.getElementById('spawnedCarsCount');
const storedCarsCount = document.getElementById('storedCarsCount');

const btnClose = document.getElementById('btnClose');
const btnFooterClose = document.getElementById('btnFooterClose');
const btnQuickStore = document.getElementById('btnQuickStore');

const editModal = document.getElementById('editModal');
const editCarName = document.getElementById('editCarName');
const editCarImage = document.getElementById('editCarImage');
const btnSaveEdit = document.getElementById('btnSaveEdit');
const btnCancelEdit = document.getElementById('btnCancelEdit');
const btnModalClose = document.getElementById('btnModalClose');

const toastContainer = document.getElementById('toastContainer');

// ============================================================
// LẮNG NGHE SỰ KIỆN TỪ LUA CLIENT
// ============================================================
window.addEventListener('message', function (event) {
  const data = event.data;

  if (data.action === 'openMenu') {
    allCars = data.cars || [];
    renderGarage(allCars);
    searchInput.value = '';
    clearSearch.style.display = 'none';
    app.style.display = 'flex';
  } else if (data.action === 'closeMenu') {
    app.style.display = 'none';
    closeEditModal();
  } else if (data.action === 'updateCars') {
    allCars = data.cars || [];
    applyFilter();
  } else if (data.action === 'notify') {
    showToast(data.message, data.type);
  }
});

// ============================================================
// ĐÓNG MENU BẰNG PHÍM ESC HOẶC NÚT ĐÓNG
// ============================================================
function postNUI(callbackName, data = {}) {
  fetch(`https://${GetParentResourceName()}/${callbackName}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
  }).catch(() => {});
}

function closeMenu() {
  app.style.display = 'none';
  closeEditModal();
  postNUI('close');
}

btnClose.addEventListener('click', closeMenu);
btnFooterClose.addEventListener('click', closeMenu);

document.addEventListener('keydown', function (e) {
  if (e.key === 'Escape') {
    if (editModal.style.display === 'flex') {
      closeEditModal();
    } else if (app.style.display === 'flex') {
      closeMenu();
    }
  }
});

// Nút cất nhanh xe đang ngồi
btnQuickStore.addEventListener('click', function () {
  postNUI('quickStore');
});

// ============================================================
// TÌM KIẾM XE
// ============================================================
searchInput.addEventListener('input', function () {
  const query = this.value.trim();
  clearSearch.style.display = query ? 'block' : 'none';
  applyFilter();
});

clearSearch.addEventListener('click', function () {
  searchInput.value = '';
  clearSearch.style.display = 'none';
  applyFilter();
});

function applyFilter() {
  const query = searchInput.value.toLowerCase().trim();
  if (!query) {
    renderGarage(allCars);
    return;
  }

  const filtered = allCars.filter(car => {
    const name = (car.name || '').toLowerCase();
    const plate = (car.plate || '').toLowerCase();
    const model = (car.modelName || '').toLowerCase();
    return name.includes(query) || plate.includes(query) || model.includes(query);
  });

  renderGarage(filtered, true);
}

// ============================================================
// KẺ RA DANH SÁCH THẺ XE (RENDER)
// ============================================================
function renderGarage(cars, isFiltering = false) {
  carsGrid.innerHTML = '';

  // Cập nhật thống kê
  const total = allCars.length;
  const spawned = allCars.filter(c => c.isSpawned).length;
  const stored = total - spawned;

  totalCarsCount.textContent = total;
  spawnedCarsCount.textContent = spawned;
  storedCarsCount.textContent = stored;

  if (total === 0) {
    emptyState.style.display = 'flex';
    noSearchResult.style.display = 'none';
    return;
  }

  emptyState.style.display = 'none';

  if (cars.length === 0 && isFiltering) {
    noSearchResult.style.display = 'flex';
    return;
  }

  noSearchResult.style.display = 'none';

  cars.forEach(car => {
    const card = createCarCard(car);
    carsGrid.appendChild(card);
  });
}

function createCarCard(car) {
  const card = document.createElement('div');
  card.className = 'car-card';

  // Xác định link ảnh: ưu tiên ảnh tùy chỉnh -> ảnh FiveM CDN -> fallback default_car.svg
  const modelName = (car.modelName || '').toLowerCase();
  const cdnImg = `https://raw.githubusercontent.com/root-cause/v-vehicle-hashes/master/images/${modelName}.webp`;
  const imgSrc = car.customImage || cdnImg;

  // Lọc thông số độ xe
  const props = car.props || {};
  const mods = props.mods || {};
  let chipsHtml = '';

  if (props.modTurbo) {
    chipsHtml += `<span class="mod-chip turbo">⚡ Turbo</span>`;
  }

  const engineMod = mods['11'];
  if (engineMod !== undefined && engineMod >= 0) {
    chipsHtml += `<span class="mod-chip engine">⚙️ Động cơ Cấp ${engineMod + 1}</span>`;
  }

  const brakesMod = mods['12'];
  if (brakesMod !== undefined && brakesMod >= 0) {
    chipsHtml += `<span class="mod-chip">🛑 Phanh Cấp ${brakesMod + 1}</span>`;
  }

  const transMod = mods['13'];
  if (transMod !== undefined && transMod >= 0) {
    chipsHtml += `<span class="mod-chip">🔄 Hộp số Cấp ${transMod + 1}</span>`;
  }

  const armorMod = mods['16'];
  if (armorMod !== undefined && armorMod >= 0) {
    chipsHtml += `<span class="mod-chip">🛡️ Giáp</span>`;
  }

  if (props.customPrimaryColor) {
    chipsHtml += `<span class="mod-chip">🎨 Sơn tùy chỉnh</span>`;
  }

  if (props.modXenon) {
    chipsHtml += `<span class="mod-chip">💡 Xenon</span>`;
  }

  if (chipsHtml === '') {
    chipsHtml = `<span class="mod-chip">Nguyên bản (Stock)</span>`;
  }

  const statusClass = car.isSpawned ? 'status-spawned' : 'status-stored';
  const statusText = car.isSpawned ? '● Ngoài phố' : '● Trong gara';

  card.innerHTML = `
    <div class="car-image-box">
      <img src="${imgSrc}" alt="${car.name}" onerror="this.onerror=null; this.src='default_car.svg';">
      <div class="status-pill ${statusClass}">${statusText}</div>
      <button class="btn-card-edit" title="Đổi tên hoặc link ảnh xe" data-id="${car.id}">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
        </svg>
      </button>
      <div class="license-plate">${car.plate || 'ADMIN'}</div>
    </div>

    <div class="car-details">
      <div class="car-title-wrap">
        <h3 class="car-name" title="${car.name}">${car.name}</h3>
        <span class="car-model-badge">${car.modelName || 'CAR'}</span>
      </div>
      <div class="mods-chips">
        ${chipsHtml}
      </div>
    </div>

    <div class="car-actions">
      <button class="btn btn-action-spawn" data-id="${car.id}">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polygon points="5 3 19 12 5 21 5 3"/>
        </svg>
        <span>Lấy Xe</span>
      </button>

      <button class="btn btn-action-store" data-id="${car.id}" title="Cất xe và lưu giữ trọn vẹn bản độ">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
          <line x1="9" y1="9" x2="15" y2="15"/>
          <line x1="15" y1="9" x2="9" y2="15"/>
        </svg>
        <span>Cất Xe</span>
      </button>

      <button class="btn-action-delete" data-id="${car.id}" title="Xóa xe khỏi danh sách">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="3 6 5 6 21 6"/>
          <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
        </svg>
      </button>
    </div>
  `;

  // Gắn sự kiện các nút
  const btnSpawn = card.querySelector('.btn-action-spawn');
  const btnStore = card.querySelector('.btn-action-store');
  const btnDelete = card.querySelector('.btn-action-delete');
  const btnEdit = card.querySelector('.btn-card-edit');

  btnSpawn.addEventListener('click', () => {
    postNUI('spawnVehicle', { carId: car.id });
  });

  btnStore.addEventListener('click', () => {
    postNUI('storeVehicle', { carId: car.id });
  });

  btnDelete.addEventListener('click', () => {
    if (confirm(`Bạn có chắc chắn muốn xóa xe "${car.name}" khỏi danh sách không?`)) {
      postNUI('deleteVehicle', { carId: car.id });
    }
  });

  btnEdit.addEventListener('click', () => {
    openEditModal(car);
  });

  return card;
}

// ============================================================
// MODAL CHỈNH SỬA TÊN VÀ ẢNH XE
// ============================================================
function openEditModal(car) {
  editingCarId = car.id;
  editCarName.value = car.name || '';
  editCarImage.value = car.customImage || '';
  editModal.style.display = 'flex';
  editCarName.focus();
}

function closeEditModal() {
  editingCarId = null;
  editModal.style.display = 'none';
}

btnCancelEdit.addEventListener('click', closeEditModal);
btnModalClose.addEventListener('click', closeEditModal);

btnSaveEdit.addEventListener('click', function () {
  if (!editingCarId) return;

  const newName = editCarName.value.trim();
  const newImg = editCarImage.value.trim();

  postNUI('updateMetadata', {
    carId: editingCarId,
    name: newName,
    customImage: newImg || null
  });

  closeEditModal();
});

// ============================================================
// HIỂN THỊ TOAST THÔNG BÁO
// ============================================================
function showToast(message, type = 'info') {
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `<span>${message.replace(/~[a-z]~/g, '')}</span>`;

  toastContainer.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(30px)';
    toast.style.transition = 'all 0.3s ease';
    setTimeout(() => {
      if (toast.parentNode) toast.parentNode.removeChild(toast);
    }, 300);
  }, 3500);
}
