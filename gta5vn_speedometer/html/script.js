// ============================================================
// GTA5VN SPEEDOMETER - NUI SCRIPT & WEB AUDIO ENGINE
// ============================================================

const container = document.getElementById('speedoContainer');
const speedNum = document.getElementById('speedNum');
const speedUnit = document.getElementById('speedUnit');
const speedBar = document.getElementById('speedBar');
const rpmBar = document.getElementById('rpmBar');
const gearBadge = document.getElementById('gearBadge');

const fuelBarFill = document.getElementById('fuelBarFill');
const fuelPercent = document.getElementById('fuelPercent');

const iconLeftTurn = document.getElementById('iconLeftTurn');
const iconRightTurn = document.getElementById('iconRightTurn');
const iconSeatbelt = document.getElementById('iconSeatbelt');
const iconLights = document.getElementById('iconLights');
const iconHandbrake = document.getElementById('iconHandbrake');
const iconEngine = document.getElementById('iconEngine');

// Độ dài chu vi của vạch tiến trình (Stroke Dasharray)
const SPEED_TOTAL_LENGTH = 377; // 75% chu vi r=80
const RPM_TOTAL_LENGTH = 433;   // 75% chu vi r=92

// ============================================================
// BỘ PHÁT ÂM THANH NỘI TẠI (WEB AUDIO API - ZERO ASSET DEPENDENCY)
// ============================================================
let audioCtx = null;

function getAudioContext() {
  if (!audioCtx) {
    audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  }
  if (audioCtx.state === 'suspended') {
    audioCtx.resume();
  }
  return audioCtx;
}

// Âm thanh thắt / tháo dây an toàn
function playSeatbeltSound(isBuckled) {
  try {
    const ctx = getAudioContext();
    const now = ctx.currentTime;

    if (isBuckled) {
      // Âm thanh click kim loại khi cài dây
      const osc1 = ctx.createOscillator();
      const gain1 = ctx.createGain();
      osc1.type = 'triangle';
      osc1.frequency.setValueAtTime(800, now);
      osc1.frequency.exponentialRampToValueAtTime(300, now + 0.05);

      gain1.gain.setValueAtTime(0.25, now);
      gain1.gain.exponentialRampToValueAtTime(0.01, now + 0.08);

      osc1.connect(gain1);
      gain1.connect(ctx.destination);
      osc1.start(now);
      osc1.stop(now + 0.08);

      // Nhịp click thứ hai sau 40ms
      const osc2 = ctx.createOscillator();
      const gain2 = ctx.createGain();
      osc2.type = 'square';
      osc2.frequency.setValueAtTime(1200, now + 0.04);
      osc2.frequency.exponentialRampToValueAtTime(500, now + 0.09);

      gain2.gain.setValueAtTime(0.18, now + 0.04);
      gain2.gain.exponentialRampToValueAtTime(0.01, now + 0.1);

      osc2.connect(gain2);
      gain2.connect(ctx.destination);
      osc2.start(now + 0.04);
      osc2.stop(now + 0.1);
    } else {
      // Âm thanh mở chốt dây an toàn
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(450, now);
      osc.frequency.exponentialRampToValueAtTime(220, now + 0.07);

      gain.gain.setValueAtTime(0.2, now);
      gain.gain.exponentialRampToValueAtTime(0.01, now + 0.07);

      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 0.07);
    }
  } catch (e) {}
}

// Âm thanh chuông cảnh báo dây an toàn (Chime)
function playSeatbeltChime() {
  try {
    const ctx = getAudioContext();
    const now = ctx.currentTime;

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(880, now); // Nốt A5

    gain.gain.setValueAtTime(0.12, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start(now);
    osc.stop(now + 0.35);
  } catch (e) {}
}

// ============================================================
// LẮNG NGHE THÔNG ĐIỆP TỪ LUA CLIENT
// ============================================================
window.addEventListener('message', function (event) {
  const data = event.data;
  if (!data) return;

  if (data.action === 'show') {
    container.style.display = 'flex';
  } else if (data.action === 'hide') {
    container.style.display = 'none';
  } else if (data.action === 'update') {
    updateSpeedometer(data);
  } else if (data.action === 'playSeatbeltSound') {
    playSeatbeltSound(data.state);
  } else if (data.action === 'playChime') {
    playSeatbeltChime();
  }
});

function updateSpeedometer(d) {
  const speed = d.speed || 0;
  const maxSpeed = d.maxSpeed || 360;
  const rpm = Math.min(Math.max(d.rpm || 0, 0), 1);
  const gear = d.gear || '1';
  const fuel = Math.min(Math.max(d.fuel || 0, 0), 100);

  // 1. TỐC ĐỘ SỐ (Định dạng 3 chữ số: 005, 085, 240)
  speedNum.textContent = String(speed).padStart(3, '0');
  if (d.unit) {
    speedUnit.textContent = d.unit;
  }

  // 2. VẠCH CÔNG-TƠ-MÉT (VÒNG TỐC ĐỘ)
  const speedPercent = Math.min(speed / maxSpeed, 1);
  const speedOffset = SPEED_TOTAL_LENGTH - (speedPercent * SPEED_TOTAL_LENGTH);
  speedBar.style.strokeDashoffset = speedOffset;

  // 3. VẠCH VÒNG TUA MÁY RPM
  const rpmOffset = RPM_TOTAL_LENGTH - (rpm * RPM_TOTAL_LENGTH);
  rpmBar.style.strokeDashoffset = rpmOffset;

  // 4. CẤP SỐ (GEAR)
  gearBadge.textContent = gear;
  gearBadge.className = 'gear-badge';
  if (gear === 'R') {
    gearBadge.classList.add('reverse');
  } else if (gear === 'P') {
    gearBadge.classList.add('park');
  }

  // 5. MỨC NHIÊN LIỆU (XĂNG)
  fuelBarFill.style.width = fuel + '%';
  fuelPercent.textContent = fuel + '%';
  if (fuel <= 20) {
    fuelBarFill.classList.add('low');
  } else {
    fuelBarFill.classList.remove('low');
  }

  // 6. XI-NHAN TRÁI / PHẢI
  if (d.leftIndicator) {
    iconLeftTurn.classList.add('active');
  } else {
    iconLeftTurn.classList.remove('active');
  }

  if (d.rightIndicator) {
    iconRightTurn.classList.add('active');
  } else {
    iconRightTurn.classList.remove('active');
  }

  // 7. DÂY AN TOÀN
  if (d.seatbelt) {
    iconSeatbelt.className = 'status-icon icon-seatbelt active';
  } else {
    iconSeatbelt.className = 'status-icon icon-seatbelt unbuckled';
  }

  // 8. ĐÈN XE
  iconLights.className = 'status-icon icon-lights';
  if (d.lights === 2) {
    iconLights.classList.add('high-beam');
  } else if (d.lights === 1) {
    iconLights.classList.add('low-beam');
  }

  // 9. PHANH TAY
  if (d.handbrake) {
    iconHandbrake.classList.add('active');
  } else {
    iconHandbrake.classList.remove('active');
  }

  // 10. ĐÈN BÁO ĐỘNG CƠ (CHECK ENGINE)
  iconEngine.className = 'status-icon icon-engine';
  const engHp = d.engineHealth || 1000;
  if (engHp < 300) {
    iconEngine.classList.add('danger');
  } else if (engHp < 600) {
    iconEngine.classList.add('warning');
  }
}
