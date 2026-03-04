import webview
import psutil
import subprocess
import os
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
        # Fetch current CPU and RAM usage
        cpu = psutil.cpu_percent(interval=None)
        ram = psutil.virtual_memory().percent
        return {'cpu': cpu, 'ram': ram}

    def launch_action(self, action):
        # Handle button clicks from the frontend
        if action == "update":
            # Opens Kitty and runs a system update
            subprocess.Popen(["kitty", "-e", "sudo", "pacman", "-Syu"])
        elif action == "hypr_config":
            # Opens your Hyprland config in Neovim
            config_path = os.path.expanduser("~/.config/hyprland/hyprland.conf")
            subprocess.Popen(["kitty", "-e", "nvim", config_path])
        elif action == "files":
            # Opens your terminal file manager
            subprocess.Popen(["kitty", "--class", "ranger", "-e", "ranger"])

# ==========================================================
# 2. FRONTEND (HTML, CSS, JS)
# ==========================================================
html_content = """
<!DOCTYPE html>
<html>
<head>
    <style>
        /* Dark theme with teal accents */
        :root {
            --bg-color: #1e1e2e;
            --panel-bg: #282a36;
            --text-main: #f8f8f2;
            --accent-teal: #00e5ff;
            --accent-hover: #00b3cc;
        }
        
        body {
            background-color: var(--bg-color);
            color: var(--text-main);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 30px;
            display: flex;
            flex-direction: column;
            height: 100vh;
            box-sizing: border-box;
        }

        h1 {
            text-align: center;
            color: var(--accent-teal);
            margin-bottom: 30px;
            font-weight: 300;
            letter-spacing: 2px;
        }

        .container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            flex-grow: 1;
        }

        .panel {
            background-color: var(--panel-bg);
            border: 1px solid #444;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        }

        .panel h2 {
            border-bottom: 2px solid var(--accent-teal);
            padding-bottom: 10px;
            margin-top: 0;
        }

        /* Progress Bars */
        .stat-row {
            margin-bottom: 15px;
        }
        .bar-container {
            background-color: #444;
            border-radius: 5px;
            height: 20px;
            width: 100%;
            overflow: hidden;
            margin-top: 5px;
        }
        .bar-fill {
            background-color: var(--accent-teal);
            height: 100%;
            width: 0%;
            transition: width 0.5s ease-in-out;
        }

        /* Buttons */
        .btn {
            display: block;
            width: 100%;
            background-color: transparent;
            color: var(--text-main);
            border: 2px solid var(--accent-teal);
            padding: 12px;
            margin-bottom: 15px;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn:hover {
            background-color: var(--accent-teal);
            color: var(--bg-color);
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
                <div class="bar-container">
                    <div id="cpu-bar" class="bar-fill"></div>
                </div>
            </div>
            <div class="stat-row">
                <label>RAM Usage: <span id="ram-val">0%</span></label>
                <div class="bar-container">
                    <div id="ram-bar" class="bar-fill"></div>
                </div>
            </div>
        </div>

        <div class="panel">
            <h2>Quick Actions</h2>
            <button class="btn" onclick="triggerAction('update')">Update System (Pacman)</button>
            <button class="btn" onclick="triggerAction('hypr_config')">Edit Hyprland Config</button>
            <button class="btn" onclick="triggerAction('files')">Open File Manager</button>
        </div>
    </div>

    <script>
        // Update hardware stats every second
        setInterval(() => {
            if (window.pywebview) {
                window.pywebview.api.get_sys_info().then(response => {
                    document.getElementById('cpu-bar').style.width = response.cpu + '%';
                    document.getElementById('cpu-val').innerText = response.cpu.toFixed(1) + '%';
                    
                    document.getElementById('ram-bar').style.width = response.ram + '%';
                    document.getElementById('ram-val').innerText = response.ram.toFixed(1) + '%';
                });
            }
        }, 1000);

        // Send button clicks to the Python backend
        function triggerAction(actionName) {
            if (window.pywebview) {
                window.pywebview.api.launch_action(actionName);
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
    # Create the native OS window and inject the HTML/JS
    window = webview.create_window(
        'Welcome Dashboard', 
        html=html_content, 
        js_api=api, 
        width=850, 
        height=500,
        frameless=False # Set to True if you want to remove the standard window title bar
    )
    webview.start()