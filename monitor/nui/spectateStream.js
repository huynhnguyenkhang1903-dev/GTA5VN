/**
 * txAdmin Spectate Stream Module (NUI-side)
 * 
 * This script runs in the FiveM NUI browser of the TARGET player.
 * It captures the game screen using CfxTexture + Three.js from @citizenfx/three,
 * creates WebRTC peer connections, and streams video to admin viewers.
 * 
 * This file must be loaded as a separate <script> in the NUI HTML,
 * NOT bundled through Vite, because it needs FiveM's native @citizenfx/three module.
 * 
 * Supports multiple concurrent viewers.
 * Automatically stops capturing when no viewers remain.
 */
(function () {
    'use strict';

    const ASPECT_RATIO_STREAMING = 600; // Scale target height
    const STREAM_FPS = 15;
    const FRAME_INTERVAL = Math.floor(1000 / STREAM_FPS);

    /**
     * @typedef {Object} SpectateStreamManagerState
     * @property {Map<string, RTCPeerConnection>} peers
     * @property {MediaStream|null} localStream
     * @property {boolean} isCapturing
     * @property {number} lastFrameTime
     * @property {number|null} animationFrameId
     */

    const state = {
        /** @type {Map<string, RTCPeerConnection>} */
        peers: new Map(),
        /** @type {MediaStream|null} */
        localStream: null,
        isCapturing: false,
        isInitialized: false,
        lastFrameTime: 0,
        animationFrameId: null,
        // Three.js references
        gameTexture: null,
        renderer: null,
        scene: null,
        camera: null,
        canvas: null,
        material: null,
        plane: null,
        mesh: null,
    };

    /**
     * Calculate scaled dimensions maintaining aspect ratio
     */
    function getScaleSize() {
        const screenW = window.innerWidth;
        const screenH = window.innerHeight;
        const scale = ASPECT_RATIO_STREAMING / screenH;
        const targetW = Math.round(screenW * scale);
        const targetH = Math.round(screenH * scale);
        return [targetW, targetH];
    }

    /**
     * Load Three.js (@citizenfx/three) bundled as three.min.js in public folder.
     */
    function loadThreeJs() {
        return new Promise(function (resolve, reject) {
            if (window.THREE) {
                resolve(window.THREE);
                return;
            }
            var script = document.createElement('script');
            script.src = 'three.min.js';
            script.onload = function () {
                if (window.THREE) {
                    resolve(window.THREE);
                } else {
                    reject(new Error('THREE global not found after loading three.min.js'));
                }
            };
            script.onerror = function () {
                reject(new Error('Failed to load three.min.js'));
            };
            document.head.appendChild(script);
        });
    }

    /**
     * Initialize the Three.js rendering pipeline for game capture
     */
    async function initRenderer() {
        if (state.isInitialized) return true;

        try {
            var THREE = await loadThreeJs();
            var OrthographicCamera = THREE.OrthographicCamera;
            var Scene = THREE.Scene;
            var ShaderMaterial = THREE.ShaderMaterial;
            var PlaneBufferGeometry = THREE.PlaneBufferGeometry || THREE.PlaneGeometry;
            var Mesh = THREE.Mesh;
            var WebGLRenderer = THREE.WebGLRenderer;
            var CfxTexture = THREE.CfxTexture;

            if (!CfxTexture) {
                console.error('[SpectateStream] CfxTexture not available in Three.js');
                return false;
            }

            state.gameTexture = new CfxTexture();
            state.gameTexture.needsUpdate = true;

            const [targetW, targetH] = getScaleSize();

            state.material = new ShaderMaterial({
                uniforms: { tDiffuse: { value: state.gameTexture } },
                vertexShader: `
                    varying vec2 vUv;
                    void main() {
                        vUv = uv;
                        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
                    }
                `,
                fragmentShader: `
                    varying vec2 vUv;
                    uniform sampler2D tDiffuse;
                    void main() {
                        gl_FragColor = texture2D(tDiffuse, vUv);
                    }
                `,
            });

            state.camera = new OrthographicCamera(
                targetW / -2, targetW / 2,
                targetH / 2, targetH / -2,
                -10000, 10000
            );
            state.camera.position.z = 100;

            state.scene = new Scene();
            state.plane = new PlaneBufferGeometry(targetW, targetH);
            state.mesh = new Mesh(state.plane, state.material);
            state.mesh.position.z = -100;
            state.scene.add(state.mesh);

            const offCanvas = document.createElement('canvas');
            offCanvas.width = targetW;
            offCanvas.height = targetH;
            state.canvas = offCanvas;

            state.renderer = new WebGLRenderer({ canvas: offCanvas });
            state.renderer.setPixelRatio(1);
            state.renderer.setSize(targetW, targetH);
            state.renderer.autoClear = false;

            state.isInitialized = true;
            // console.log('[SpectateStream] Renderer initialized (' + targetW + 'x' + targetH + ')');
            return true;
        } catch (e) {
            console.error('[SpectateStream] Failed to initialize renderer:', e);
            return false;
        }
    }

    /**
     * Animation loop - renders the game texture to the offscreen canvas
     */
    function animate() {
        if (!state.isCapturing) return;
        state.animationFrameId = requestAnimationFrame(animate);

        const now = Date.now();
        if (now - state.lastFrameTime < FRAME_INTERVAL) return;
        state.lastFrameTime = now;

        try {
            state.renderer.clear();
            state.renderer.render(state.scene, state.camera);
        } catch (e) {
            console.error('[SpectateStream] Render error:', e);
        }
    }

    /**
     * Start capturing the game screen
     */
    function startCapture() {
        if (state.isCapturing) return true;
        if (!state.isInitialized) return false;

        state.isCapturing = true;
        state.localStream = state.canvas.captureStream(STREAM_FPS);
        state.animationFrameId = requestAnimationFrame(animate);
        // console.log('[SpectateStream] Capture started');
        return true;
    }

    /**
     * Stop capturing when no more peers
     */
    function stopCapture() {
        if (!state.isCapturing) return;

        state.isCapturing = false;

        if (state.animationFrameId) {
            cancelAnimationFrame(state.animationFrameId);
            state.animationFrameId = null;
        }

        if (state.localStream) {
            var tracks = state.localStream.getTracks();
            for (var i = 0; i < tracks.length; i++) {
                tracks[i].stop();
            }
            state.localStream = null;
        }

        // Dispose Three.js resources to free WebGL context
        if (state.renderer) {
            state.renderer.dispose();
            state.renderer = null;
        }
        if (state.material) {
            state.material.dispose();
            state.material = null;
        }
        if (state.plane) {
            state.plane.dispose();
            state.plane = null;
        }
        if (state.gameTexture) {
            state.gameTexture.dispose();
            state.gameTexture = null;
        }
        if (state.scene && state.mesh) {
            state.scene.remove(state.mesh);
        }
        state.mesh = null;
        state.scene = null;
        state.camera = null;
        state.canvas = null;
        state.isInitialized = false;

        // console.log('[SpectateStream] Capture stopped, resources disposed');
    }

    /**
     * Send a WebRTC signal to server via NUI callback
     */
    function sendSignal(peerKey, signal) {
        fetch('https://monitor/txSpectateStream:signal', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ peerKey: peerKey, signal: signal }),
        }).catch(function (err) {
            console.error('[SpectateStream] Failed to send signal:', err);
        });
    }

    /**
     * Send an error to server via NUI callback
     */
    function sendError(peerKey, error) {
        fetch('https://monitor/txSpectateStream:error', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ peerKey: peerKey, error: error }),
        }).catch(function (err) {
            console.error('[SpectateStream] Failed to send error:', err);
        });
    }

    /**
     * Destroy a specific peer and cleanup if no more peers
     */
    function destroyPeer(peerKey) {
        var pc = state.peers.get(peerKey);
        if (pc) {
            try {
                var senders = pc.getSenders();
                for (var i = 0; i < senders.length; i++) {
                    try { pc.removeTrack(senders[i]); } catch (_) { }
                }
                pc.close();
                pc.onicecandidate = null;
                pc.onconnectionstatechange = null;
                pc.oniceconnectionstatechange = null;
            } catch (_) { }
            state.peers.delete(peerKey);
        }

        // If no more peers, stop capturing
        if (state.peers.size === 0) {
            stopCapture();
        }
    }

    /**
     * Handle a new viewer starting to spectate
     */
    async function handleStart(peerKey, iceServers) {
        // console.log('[SpectateStream] New viewer:', peerKey);

        // Destroy existing peer with same key
        if (state.peers.has(peerKey)) {
            destroyPeer(peerKey);
        }

        // Ensure renderer is initialized
        var rendererOk = await initRenderer();
        if (!rendererOk) {
            sendError(peerKey, 'Failed to initialize game capture renderer');
            return;
        }

        // Ensure capture is running
        if (!state.isCapturing) {
            if (!startCapture()) {
                sendError(peerKey, 'Failed to start game capture');
                return;
            }
        }

        try {
            var pc = new RTCPeerConnection({ iceServers: iceServers });

            // Add the video track
            var videoTrack = state.localStream.getVideoTracks()[0];
            if (!videoTrack) {
                sendError(peerKey, 'No video track available');
                return;
            }
            pc.addTrack(videoTrack, state.localStream);

            // ICE candidate handler
            pc.onicecandidate = function (e) {
                if (e.candidate) {
                    sendSignal(peerKey, {
                        type: 'candidate',
                        data: e.candidate,
                    });
                }
            };

            // Connection state monitoring
            pc.onconnectionstatechange = function () {
                var s = pc.connectionState;
                if (s === 'failed' || s === 'disconnected' || s === 'closed') {
                    // console.log('[SpectateStream] Peer ' + peerKey + ' connection ' + s);
                    destroyPeer(peerKey);
                }
            };

            pc.oniceconnectionstatechange = function () {
                var s = pc.iceConnectionState;
                if (s === 'failed' || s === 'disconnected') {
                    // console.log('[SpectateStream] Peer ' + peerKey + ' ICE ' + s);
                    destroyPeer(peerKey);
                }
            };

            state.peers.set(peerKey, pc);

            // Create and send offer
            var offer = await pc.createOffer();
            await pc.setLocalDescription(offer);

            sendSignal(peerKey, {
                type: 'offer',
                data: pc.localDescription,
            });

            // Handshake timeout
            setTimeout(function () {
                var peer = state.peers.get(peerKey);
                if (peer && peer.connectionState !== 'connected') {
                    // console.log('[SpectateStream] Peer ' + peerKey + ' handshake timeout');
                    destroyPeer(peerKey);
                }
            }, 15000);

        } catch (e) {
            console.error('[SpectateStream] Failed to create peer:', e);
            sendError(peerKey, 'Failed to create WebRTC peer: ' + e.message);
        }
    }

    /**
     * Handle a signal from the viewer (answer, candidate, stop)
     */
    async function handleSignal(peerKey, signal) {
        if (signal.type === 'stop') {
            destroyPeer(peerKey);
            return;
        }

        var pc = state.peers.get(peerKey);
        if (!pc) {
            console.warn('[SpectateStream] Signal for unknown peer:', peerKey);
            return;
        }

        try {
            if (signal.type === 'answer') {
                await pc.setRemoteDescription(new RTCSessionDescription(signal.data));
            } else if (signal.type === 'candidate') {
                await pc.addIceCandidate(new RTCIceCandidate(signal.data));
            }
        } catch (err) {
            console.error('[SpectateStream] Signal handling error:', err);
        }
    }

    /**
     * Handle stop request for a specific peer
     */
    function handleStop(peerKey) {
        // console.log('[SpectateStream] Viewer stopped:', peerKey);
        destroyPeer(peerKey);
    }

    // =============================================
    // Listen for NUI messages from Lua client
    // =============================================
    window.addEventListener('message', function (event) {
        if (!event.data || !event.data.action) return;

        var action = event.data.action;
        var data = event.data.data;

        switch (action) {
            case 'txSpectateStream:start':
                handleStart(data.peerKey, data.iceServers);
                break;
            case 'txSpectateStream:stop':
                handleStop(data.peerKey);
                break;
            case 'txSpectateStream:signal':
                handleSignal(data.peerKey, data.signal);
                break;
        }
    });

    // Notify Lua that the spectate stream module is ready
    fetch('https://monitor/txSpectateStream:ready', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({}),
    }).catch(function () {});

    // console.log('[SpectateStream] Module loaded');
})();
