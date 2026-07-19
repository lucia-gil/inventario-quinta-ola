<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>¡Ups! Perdido en la Ola | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=22" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body {
            font-family: 'Montserrat', sans-serif;
            background: linear-gradient(135deg, var(--purple-bg) 0%, var(--pink-bg) 50%, #FFF8E1 100%);
            min-height: 100vh;
            margin: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .error-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: 0 20px 60px rgba(91, 31, 168, 0.15);
            padding: 2.5rem;
            max-width: 600px;
            width: 100%;
            text-align: center;
            border: 1px solid var(--gray-100);
        }

        .error-code {
            font-size: 6rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--purple) 0%, var(--pink) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            line-height: 1;
            margin: 0;
            letter-spacing: -4px;
        }

        .error-title {
            font-size: 1.4rem;
            font-weight: 800;
            color: var(--gray-800);
            margin: 0.5rem 0 0.5rem;
        }

        .error-message {
            font-size: 0.92rem;
            color: var(--gray-600);
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }

        /* ─── Mini juego ─── */
        .game-container {
            position: relative;
            width: 100%;
            max-width: 520px;
            margin: 0 auto 1.75rem;
            height: 280px;
            background: linear-gradient(to bottom, #BAE6FD 0%, #7DD3FC 100%);
            border-radius: var(--radius-md);
            overflow: hidden;
            border: 2px solid var(--purple-bg);
            cursor: crosshair;
        }

        .game-score {
            position: absolute;
            top: 0.75rem;
            left: 0.75rem;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(8px);
            color: var(--purple);
            font-weight: 700;
            padding: 0.4rem 0.85rem;
            border-radius: var(--radius-full);
            z-index: 20;
            font-size: 0.8rem;
            display: flex;
            align-items: center;
            gap: 0.45rem;
            box-shadow: var(--shadow-sm);
        }
        .game-score i { width: 14px; height: 14px; color: var(--pink); }
        .game-score-value {
            color: var(--pink);
            font-weight: 900;
            font-size: 0.95rem;
        }

        .game-overlay {
            position: absolute;
            inset: 0;
            background: rgba(91, 31, 168, 0.85);
            backdrop-filter: blur(4px);
            z-index: 30;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: var(--white);
            transition: opacity 0.3s;
        }
        .game-overlay p {
            font-size: 0.9rem;
            margin-bottom: 1rem;
            font-weight: 600;
        }
        .game-play-btn {
            background: linear-gradient(135deg, var(--pink) 0%, var(--pink-dark) 100%);
            color: var(--white);
            border: none;
            padding: 0.7rem 1.75rem;
            border-radius: var(--radius-full);
            font-weight: 800;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all var(--transition);
            box-shadow: 0 6px 18px rgba(233, 30, 140, 0.4);
            font-family: inherit;
        }
        .game-play-btn:hover {
            transform: translateY(-2px) scale(1.03);
        }

        .ocean {
            height: 60px;
            width: 100%;
            position: absolute;
            bottom: 0;
            left: 0;
            background: #0EA5E9;
            overflow: hidden;
            z-index: 1;
        }
        .wave, .wave2 {
            position: absolute;
            width: 200%;
            height: 80px;
            bottom: 0;
            background-size: 1000px 80px;
        }
        .wave {
            background: url('data:image/svg+xml;utf8,<svg viewBox="0 0 1440 320" xmlns="http://www.w3.org/2000/svg"><path fill="%2338bdf8" d="M0,160L48,170.7C96,181,192,203,288,192C384,181,480,139,576,144C672,149,768,203,864,202.7C960,203,1056,149,1152,138.7C1248,128,1344,160,1392,176L1440,192L1440,320L0,320Z"></path></svg>') repeat-x;
            animation: wave-animation 4s linear infinite;
        }
        .wave2 {
            background: url('data:image/svg+xml;utf8,<svg viewBox="0 0 1440 320" xmlns="http://www.w3.org/2000/svg"><path fill="%230284c7" fill-opacity="0.5" d="M0,192L48,181.3C96,171,192,149,288,165.3C384,181,480,235,576,245.3C672,256,768,224,864,197.3C960,171,1056,149,1152,160C1248,171,1344,213,1392,234.7L1440,256L1440,320L0,320Z"></path></svg>') repeat-x;
            animation: wave-animation 6s linear infinite reverse;
        }
        @keyframes wave-animation {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }

        #gameCanvas {
            touch-action: none;
            z-index: 10;
            position: relative;
            width: 100%;
            height: 100%;
        }

        .btn-home {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.8rem 2rem;
            border-radius: var(--radius-full);
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            color: var(--white);
            text-decoration: none;
            font-weight: 800;
            font-size: 0.9rem;
            transition: all var(--transition);
            box-shadow: 0 4px 14px rgba(233, 30, 140, 0.3);
        }
        .btn-home:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(233, 30, 140, 0.4);
        }
        .btn-home i { width: 16px; height: 16px; }
    </style>
</head>
<body>

<div class="error-card">

    <h1 class="error-code">404</h1>
    <h2 class="error-title">¡Vaya! Te llevó la corriente</h2>
    <p class="error-message">
        La página que buscas se perdió en el océano, pero ya que estás aquí...
        <strong style="color: var(--purple);">¡Ayúdanos a rescatar el inventario que cayó al agua!</strong>
    </p>

    <div class="game-container" id="gameContainer">

        <div class="game-score">
            <i data-lucide="package"></i>
            Rescatados:
            <span class="game-score-value" id="scoreDisplay">0</span>
        </div>

        <div class="game-overlay" id="startOverlay">
            <p>Mueve el mouse para atrapar los items</p>
            <button id="playButton" class="game-play-btn">¡Jugar Ahora!</button>
        </div>

        <div class="ocean">
            <div class="wave2"></div>
            <div class="wave"></div>
        </div>

        <canvas id="gameCanvas"></canvas>
    </div>

    <a href="<%= ctx %>/HomeServlet" class="btn-home">
        <i data-lucide="home"></i>
        Volver a Tierra Firme
    </a>

</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        if (typeof lucide !== 'undefined') lucide.createIcons();

        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');
        const container = document.getElementById('gameContainer');
        const scoreDisplay = document.getElementById('scoreDisplay');
        const startOverlay = document.getElementById('startOverlay');
        const playButton = document.getElementById('playButton');

        let score = 0;
        let isPlaying = false;
        const emojis = ['🧱', '🔧', '🪣', '📦', '🪜', '🎒', '🧰'];
        let items = [];

        let player = {
            x: 150,
            y: 250,
            width: 80,
            height: 12,
            color: '#E91E8C'
        };

        function resizeCanvas() {
            canvas.width = container.clientWidth;
            canvas.height = container.clientHeight;
            player.y = canvas.height - 50;
        }

        window.addEventListener('resize', resizeCanvas);
        setTimeout(resizeCanvas, 50);

        function spawnItem() {
            if (!isPlaying) return;
            items.push({
                x: Math.random() * (canvas.width - 40) + 20,
                y: -30,
                speed: 2.5 + Math.random() * 2,
                emoji: emojis[Math.floor(Math.random() * emojis.length)],
                size: 26
            });
            setTimeout(spawnItem, 700 + Math.random() * 800);
        }

        function update() {
            if (!isPlaying) return;
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            ctx.fillStyle = player.color;
            ctx.beginPath();
            if (ctx.roundRect) {
                ctx.roundRect(player.x, player.y, player.width, player.height, 6);
            } else {
                ctx.rect(player.x, player.y, player.width, player.height);
            }
            ctx.fill();

            for (let i = items.length - 1; i >= 0; i--) {
                let item = items[i];
                item.y += item.speed;

                ctx.font = item.size + "px Arial";
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                ctx.fillText(item.emoji, item.x, item.y);

                if (item.y + (item.size/2) >= player.y &&
                    item.y - (item.size/2) <= player.y + player.height &&
                    item.x + (item.size/2) >= player.x &&
                    item.x - (item.size/2) <= player.x + player.width) {
                    score++;
                    scoreDisplay.innerText = score;
                    items.splice(i, 1);
                    player.color = '#5B1FA8';
                    setTimeout(() => player.color = '#E91E8C', 150);
                } else if (item.y > canvas.height + 40) {
                    items.splice(i, 1);
                }
            }
            requestAnimationFrame(update);
        }

        function movePlayer(e) {
            if (!isPlaying) return;
            const rect = canvas.getBoundingClientRect();
            let clientX;
            if (e.type.includes('mouse')) {
                clientX = e.clientX;
            } else if (e.touches && e.touches.length > 0) {
                clientX = e.touches[0].clientX;
            }
            if (clientX !== undefined) {
                let xPos = clientX - rect.left - (player.width / 2);
                player.x = Math.max(0, Math.min(xPos, canvas.width - player.width));
            }
        }

        window.addEventListener('mousemove', movePlayer);
        window.addEventListener('touchmove', movePlayer, { passive: true });

        playButton.addEventListener('click', () => {
            startOverlay.style.opacity = '0';
            setTimeout(() => {
                startOverlay.style.display = 'none';
                if (!isPlaying) {
                    resizeCanvas();
                    isPlaying = true;
                    score = 0;
                    scoreDisplay.innerText = score;
                    items = [];
                    spawnItem();
                    update();
                }
            }, 300);
        });
    });
</script>

</body>
</html>