import webview
import psutil
import subprocess
import os

# Force the WM_CLASS so Hyprland catches it instantly (Fixes the tiling issue)
os.environ['RESOURCE_NAME'] = 'sys-dashboard'

# Force software rendering to prevent GBM buffer crashes on NVIDIA/Intel
os.environ['WEBKIT_DISABLE_COMPOSITING_MODE'] = '1'
os.environ['WEBKIT_DISABLE_DMABUF_RENDERER'] = '1'
# Force XWayland instead of pure Wayland to prevent Protocol Error 71
os.environ['GDK_BACKEND'] = 'x11'

# ==========================================================
# 1. PYTHON BACKEND (The API)
# ==========================================================
class DashboardAPI:
    def get_sys_info(self):
        # CPU & RAM Usage
        cpu = psutil.cpu_percent(interval=None)
        ram = psutil.virtual_memory().percent

        # CPU Temperature
        cpu_temp = 0
        try:
            temps = psutil.sensors_temperatures()
            if 'coretemp' in temps:
                cpu_temp = temps['coretemp'][0].current
            elif 'k10temp' in temps:
                cpu_temp = temps['k10temp'][0].current
            elif 'acpitz' in temps:
                cpu_temp = temps['acpitz'][0].current
            elif temps:
                cpu_temp = list(temps.values())[0][0].current
        except Exception:
            pass

        # GPU Usage & Temperature (NVIDIA)
        gpu_usage = 0
        gpu_temp = 0
        try:
            smi_output = subprocess.check_output(
                ['nvidia-smi', '--query-gpu=utilization.gpu,temperature.gpu', '--format=csv,noheader,nounits'],
                encoding='utf-8'
            ).strip()
            
            if smi_output:
                gpu_usage_str, gpu_temp_str = smi_output.split(', ')
                gpu_usage = int(gpu_usage_str)
                gpu_temp = int(gpu_temp_str)
        except Exception:
            pass 

        return {
            'cpu': cpu, 
            'ram': ram, 
            'cpu_temp': cpu_temp,
            'gpu_usage': gpu_usage,
            'gpu_temp': gpu_temp
        }

    def launch_action(self, action, editor="nvim"):
        configs = {
            "pacman": {"path": "/etc/pacman.conf", "needs_sudo": True},
            "grub": {"path": "/etc/default/grub", "needs_sudo": True},
            "mkinitcpio": {"path": "/etc/mkinitcpio.conf", "needs_sudo": True},
            "waybar": {"path": os.path.expanduser("~/.config/waybar/config"), "needs_sudo": False},
            "hyprland": {"path": os.path.expanduser("~/.config/hyprland/hyprland.conf"), "needs_sudo": False},
            "swaync": {"path": os.path.expanduser("~/.config/swaync/config.json"), "needs_sudo": False},
        }

        # Standalone Quick Actions
        if action == "update":
            subprocess.Popen(["kitty", "-e", "sudo", "pacman", "-Syu"])
            return
        elif action == "update_yay":
            # AUR helpers like yay should NOT be run with sudo directly
            subprocess.Popen(["kitty", "-e", "yay", "-Syu"])
            return
        elif action == "files":
            subprocess.Popen(["kitty", "--class", "ranger", "-e", "ranger"])
            return
        elif action == "vman":
            subprocess.Popen([os.path.expanduser("~/scripts/v-man.sh")])
            return
        elif action == "vpn":
            subprocess.Popen([os.path.expanduser("~/scripts/wireguard.sh")])
            return

        # Configuration Editor Actions
        if action in configs:
            target = configs[action]["path"]
            needs_sudo = configs[action]["needs_sudo"]

            if editor == "nvim":
                if needs_sudo:
                    subprocess.Popen(["kitty", "-e", "sudo", "nvim", target])
                else:
                    subprocess.Popen(["kitty", "-e", "nvim", target])
            
            elif editor == "vscode":
                subprocess.Popen(["code", target])

# ==========================================================
# 2. FRONTEND (HTML, CSS, JS)
# ==========================================================
html_content = """
<!DOCTYPE html>
<html>
<head>
    <style>
        /* Catppuccin Mocha Palette */
        :root {
            --base: #1e1e2e;
            --mantle: #181825;
            --surface0: #313244;
            --surface1: #45475a;
            --text: #cdd6f4;
            --subtext0: #a6adc8;
            --mauve: #cba6f7;
            --blue: #89b4fa;
            --sapphire: #74c7ec;
            --green: #a6e3a1;
            --peach: #fab387;
            --yellow: #f9e2af;
            --red: #f38ba8;
            --overlay0: #6c7086;
        }
        
        body {
            background-color: var(--base);
            color: var(--text);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            height: 100vh;
            box-sizing: border-box;
        }

        h1 {
            text-align: center;
            color: var(--mauve);
            margin-bottom: 20px;
            font-weight: 400;
            letter-spacing: 2px;
        }

        .container {
            display: grid;
            grid-template-columns: 1fr 1.2fr;
            gap: 20px;
            flex-grow: 1;
            overflow: hidden;
        }

        .panel {
            background-color: var(--mantle);
            border: 1px solid var(--surface0);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.2);
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }

        .panel h2 {
            border-bottom: 2px solid var(--surface1);
            padding-bottom: 10px;
            margin-top: 0;
            font-size: 18px;
            color: var(--blue);
        }

        /* Progress Bars */
        .stat-row {
            margin-bottom: 12px; 
            color: var(--subtext0);
            font-size: 14px;
        }
        .stat-row span {
            color: var(--text);
            font-weight: bold;
        }
        .bar-container {
            background-color: var(--surface0);
            border-radius: 6px;
            height: 10px; 
            width: 100%;
            overflow: hidden;
            margin-top: 4px;
        }
        .bar-fill {
            background-color: var(--green);
            height: 100%;
            width: 0%;
            transition: width 0.5s ease-in-out;
        }
        
        /* Bar Colors */
        #cpu-bar { background-color: var(--sapphire); }
        #cpu-temp-bar { background-color: var(--peach); }
        #ram-bar { background-color: var(--mauve); }
        #gpu-use-bar { background-color: var(--yellow); }
        #gpu-temp-bar { background-color: var(--red); }

        /* Editor Selection */
        .editor-select {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
            background-color: var(--surface0);
            padding: 10px 15px;
            border-radius: 8px;
            border: 1px solid var(--surface1);
        }
        .editor-select label {
            cursor: pointer;
            color: var(--text);
        }
        .editor-select input[type="radio"] {
            accent-color: var(--mauve);
            cursor: pointer;
        }

        /* Buttons */
        .btn {
            background-color: var(--surface0);
            color: var(--text);
            border: 1px solid var(--surface1);
            padding: 10px;
            border-radius: 8px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s ease;
            text-align: center;
            width: 100%;
        }
        .btn:hover {
            background-color: var(--surface1);
            border-color: var(--blue);
            color: var(--blue);
        }

        .config-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        /* Utility class to make a button span both columns */
        .span-2 {
            grid-column: span 2;
        }
        
        .section-label {
            color: var(--subtext0);
            font-size: 13px;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: bold;
        }
    </style>
</head>
<body>

    <h1>SYSTEM DASHBOARD</h1>

    <div class="container">
        <div class="panel">
            <h2>Hardware Status</h2>
            
            <div class="stat-row">
                <label>CPU Usage: <span id="cpu-val">0%</span></label>
                <div class="bar-container"><div id="cpu-bar" class="bar-fill"></div></div>
            </div>
            
            <div class="stat-row">
                <label>CPU Temp: <span id="cpu-temp-val">0°C</span></label>
                <div class="bar-container"><div id="cpu-temp-bar" class="bar-fill"></div></div>
            </div>

            <div class="stat-row">
                <label>RAM Usage: <span id="ram-val">0%</span></label>
                <div class="bar-container"><div id="ram-bar" class="bar-fill"></div></div>
            </div>
            
            <div class="stat-row">
                <label>GPU Usage: <span id="gpu-use-val">0%</span></label>
                <div class="bar-container"><div id="gpu-use-bar" class="bar-fill"></div></div>
            </div>
            
            <div class="stat-row">
                <label>GPU Temp: <span id="gpu-temp-val">0°C</span></label>
                <div class="bar-container"><div id="gpu-temp-bar" class="bar-fill"></div></div>
            </div>
            
            <h2 style="margin-top: 15px;">Quick Actions</h2>
            <div class="config-grid">
                <button class="btn" onclick="triggerAction('update')">Pacman Update</button>
                <button class="btn" onclick="triggerAction('update_yay')">AUR Update (Yay)</button>
                <button class="btn" onclick="triggerAction('files')">File Manager</button>
                <button class="btn" onclick="triggerAction('vman')">Toggle VMs</button>
                <button class="btn span-2" onclick="triggerAction('vpn')">Toggle VPN</button>
            </div>
        </div>

        <div class="panel">
            <h2>Configuration Editor</h2>
            
            <div class="editor-select">
                <span style="color: var(--subtext0); font-weight: bold;">Editor:</span>
                <input type="radio" id="nvim" name="editor" value="nvim" checked>
                <label for="nvim">Neovim</label>
                <input type="radio" id="vscode" name="editor" value="vscode">
                <label for="vscode">VS Code</label>
            </div>

            <div class="section-label">System (Root)</div>
            <div class="config-grid">
                <button class="btn" onclick="triggerAction('pacman')">pacman.conf</button>
                <button class="btn" onclick="triggerAction('grub')">GRUB</button>
                <button class="btn" onclick="triggerAction('mkinitcpio')">mkinitcpio.conf</button>
            </div>

            <div class="section-label">Userland</div>
            <div class="config-grid">
                <button class="btn" onclick="triggerAction('hyprland')">Hyprland</button>
                <button class="btn" onclick="triggerAction('waybar')">Waybar</button>
                <button class="btn" onclick="triggerAction('swaync')">SwayNC</button>
            </div>
        </div>
    </div>

    <script>
        setInterval(() => {
            if (window.pywebview) {
                window.pywebview.api.get_sys_info().then(response => {
                    document.getElementById('cpu-bar').style.width = response.cpu + '%';
                    document.getElementById('cpu-val').innerText = response.cpu.toFixed(1) + '%';
                    
                    let safeCpuTemp = Math.min(response.cpu_temp, 100);
                    document.getElementById('cpu-temp-bar').style.width = safeCpuTemp + '%';
                    document.getElementById('cpu-temp-val').innerText = response.cpu_temp + '°C';

                    document.getElementById('ram-bar').style.width = response.ram + '%';
                    document.getElementById('ram-val').innerText = response.ram.toFixed(1) + '%';
                    
                    document.getElementById('gpu-use-bar').style.width = response.gpu_usage + '%';
                    document.getElementById('gpu-use-val').innerText = response.gpu_usage + '%';
                    
                    let safeGpuTemp = Math.min(response.gpu_temp, 100);
                    document.getElementById('gpu-temp-bar').style.width = safeGpuTemp + '%';
                    document.getElementById('gpu-temp-val').innerText = response.gpu_temp + '°C';
                });
            }
        }, 1000);

        function triggerAction(actionName) {
            if (window.pywebview) {
                const selectedEditor = document.querySelector('input[name="editor"]:checked').value;
                window.pywebview.api.launch_action(actionName, selectedEditor);
            }
        }
    </script>
</body>
</html>
"""

# ==========================================================
# 3. APP INITIALIZATION
# ==========================================================
if __name__ == '__main__':
    api = DashboardAPI()
    window = webview.create_window(
        'Welcome Dashboard', 
        html=html_content, 
        js_api=api, 
        width=1200, 
        height=900,
        frameless=False 
    )
    webview.start()