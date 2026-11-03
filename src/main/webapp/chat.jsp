<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Chat"%>
<%@ page import="java.util.List"%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parent-Teacher Hub - Keedflix Centre</title>

    <style>
        :root {
            --bg-canvas: #FFFDF7;
            --border-dark: #2D3436;
            --yellow-accent: #FFD166;
            --coral-accent: #FF6B6B;
            --mint-accent: #2EC4B6;
            --purple-accent: #7C3AED;
            --purple-light: #F3E8FF;
            --shadow-sm: 2px 2px 0px 0px var(--border-dark);
            --shadow-md: 3px 3px 0px 0px var(--border-dark);
            --shadow-lg: 4px 4px 0px 0px var(--border-dark);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body, html {
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background-color: var(--bg-canvas);
            color: var(--border-dark);
        }

        .app-layout {
            display: flex;
            min-height: 100vh;
            width: 100%;
        }

        .app-sidebar-wrapper {
            width: 280px;
            flex-shrink: 0;
            background: #FFFFFF;
            border-right: 3px solid var(--border-dark);
        }

        .app-main-wrapper {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
            background-color: var(--bg-canvas);
        }

        .app-header-wrapper {
            flex-shrink: 0;
            background: #FFFFFF;
            border-bottom: 3px solid var(--border-dark);
        }

        .app-content-body {
            flex-grow: 1;
            padding: 24px;
            overflow-y: auto;
        }

        .nb-card {
            background-color: #FFFFFF;
            border: 3px solid var(--border-dark);
            border-radius: 24px;
            box-shadow: var(--shadow-lg);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: 680px;
        }

        .nb-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 0.7rem;
            font-weight: 900;
            text-transform: uppercase;
            border: 1.5px solid var(--border-dark);
        }
        .badge-purple { background-color: #EEF2FF; color: #4338CA; border-color: #C7D2FE; }

        .nb-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 8px 16px;
            border: 2px solid var(--border-dark);
            border-radius: 14px;
            background-color: #FFFFFF;
            color: var(--border-dark);
            font-weight: 900;
            font-size: 0.8rem;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: all 0.1s ease;
        }
        .nb-btn:hover { transform: translate(-1px, -1px); box-shadow: var(--shadow-md); }
        .nb-btn-yellow { background-color: var(--yellow-accent); }

        .nb-input {
            width: 100%;
            padding: 10px 14px;
            border: 2px solid var(--border-dark);
            border-radius: 12px;
            background-color: var(--bg-canvas);
            font-weight: 700;
            font-size: 0.85rem;
            color: var(--border-dark);
            outline: none;
        }

        .chat-workspace {
            display: flex;
            flex-grow: 1;
            overflow: hidden;
        }

        .chat-sidebar {
            width: 280px;
            border-right: 2px solid var(--border-dark);
            background: #FAFAF9;
            display: flex;
            flex-direction: column;
        }

        .chat-main {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            background: #FFFDF7;
            position: relative;
        }

        .contact-item {
            padding: 12px 14px;
            border-bottom: 1px solid #E2E8F0;
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            background-color: #FFFFFF;
            border-left: 4px solid var(--border-dark);
        }

        .msg-stream {
            flex-grow: 1;
            padding: 16px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 12px;
            background-image: radial-gradient(rgba(45, 52, 54, 0.08) 1.5px, transparent 1.5px);
            background-size: 16px 16px;
        }

        .msg-bubble {
            max-width: 75%;
            padding: 12px 16px;
            border-radius: 18px;
            border: 2px solid var(--border-dark);
            box-shadow: var(--shadow-sm);
            font-size: 0.85rem;
            font-weight: 600;
            line-height: 1.4;
        }
        .msg-own {
            align-self: flex-end;
            background-color: #F3E8FF;
            border-top-right-radius: 2px;
        }
        .msg-other {
            align-self: flex-start;
            background-color: #FFFFFF;
            border-top-left-radius: 2px;
        }

        .msg-meta {
            font-size: 0.65rem;
            color: #64748B;
            margin-top: 4px;
            text-align: right;
            font-weight: 700;
        }
    </style>
</head>
<body>

<div class="app-layout">

    <aside class="app-sidebar-wrapper">
        <jsp:include page="sidebar.jsp" />
    </aside>

    <main class="app-main-wrapper">

        <div class="app-header-wrapper">
            <jsp:include page="header.jsp" />
        </div>

        <div class="app-content-body">
            <div class="nb-card">

                <div style="background-color: var(--yellow-accent); border-bottom: 3px solid var(--border-dark); padding: 14px 20px; display: flex; justify-content: space-between; align-items: center;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="width: 38px; height: 38px; background: #FFF; border: 2px solid var(--border-dark); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 18px; box-shadow: var(--shadow-sm);">
                            💬
                        </div>
                        <div>
                            <h2 style="font-size: 1.1rem; font-weight: 900;">Parent-Teacher Hub</h2>
                            <p style="font-size: 0.72rem; font-weight: 700; color: #475569;">Komunikasi langsung antara Ibu Bapa (ID: ${parentID}) dan Guru (ID: ${teacherID})</p>
                        </div>
                    </div>
                    <span class="nb-badge badge-purple">Chat ID Ref: DB Active</span>
                </div>

                <div class="chat-workspace">

                    <div class="chat-sidebar">
                        <div class="contact-item">
                            <div style="width: 36px; height: 36px; background: var(--yellow-accent); border: 2px solid var(--border-dark); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                                👩‍🏫
                            </div>
                            <div>
                                <h4 style="font-size: 0.82rem; font-weight: 900;">Cikgu Clara (Teacher ID: ${teacherID})</h4>
                                <p style="font-size: 0.68rem; color: #64748B; font-weight: 700;">Sesi Aktif</p>
                            </div>
                        </div>
                    </div>

                    <div class="chat-main">

                        <div style="padding: 10px 16px; border-bottom: 2px solid var(--border-dark); background: #FFF; display: flex; justify-content: space-between; align-items: center;">
                            <h4 style="font-size: 0.88rem; font-weight: 900;">
                                Perbualan Langsung (Parent ID: ${parentID} ↔ Teacher ID: ${teacherID})
                            </h4>
                            <span style="font-size: 0.65rem; color: #10B981; font-weight: 800;">● Terhubung Pangkalan Data CHAT</span>
                        </div>

                        <div class="msg-stream" id="msgStream">
                            <c:forEach var="chat" items="${chatHistory}">
                                <c:set var="isOwn" value="${(chat.senderRole == 'parent' && senderRole == 'parent') || (chat.senderRole != 'parent' && senderRole != 'parent')}" />
                                <div class="msg-bubble ${isOwn ? 'msg-own' : 'msg-other'}">
                                    <div style="font-size: 0.65rem; font-weight: 900; color: #64748B; margin-bottom: 2px;">
                                        Role: ${chat.senderRole} (Chat #${chat.chatID})
                                    </div>
                                    <div>${chat.messageContent}</div>
                                    <div class="msg-meta">${chat.formattedTime}</div>
                                </div>
                            </c:forEach>
                        </div>

                        <div style="padding: 6px 12px; background: #FFF; border-top: 1px solid #CBD5E1; display: flex; gap: 6px;">
                            <button type="button" class="nb-btn" style="font-size: 0.7rem; padding: 4px 10px;" onclick="setQuickMsg('Bagaimanakah perkembangan kemahiran membaca anak saya minggu ini?')">
                                📊 Tanya Kemahiran Membaca
                            </button>
                            <button type="button" class="nb-btn" style="font-size: 0.7rem; padding: 4px 10px;" onclick="setQuickMsg('Terima kasih cikgu atas maklum balas yang diberikan!')">
                                ❤️ Ucapan Terima Kasih
                            </button>
                        </div>

                        <form action="${pageContext.request.contextPath}/ChatServlet" method="POST" style="padding: 10px 14px; background: #FFF; border-top: 2px solid var(--border-dark); display: flex; gap: 8px;">
                            <input type="hidden" name="parentID" value="${parentID}">
                            <input type="hidden" name="teacherID" value="${teacherID}">
                            <input type="hidden" name="senderRole" value="${senderRole}">

                            <input type="text" name="messageContent" id="messageInput" class="nb-input" placeholder="Tulis mesej di sini..." required autocomplete="off">
                            <button type="submit" class="nb-btn nb-btn-yellow" style="padding: 8px 18px;">
                                🚀 Hantar
                            </button>
                        </form>

                    </div>
                </div>

            </div>
        </div>
    </main>
</div>

<script>
    function setQuickMsg(text) {
        document.getElementById('messageInput').value = text;
    }

    window.onload = function() {
        var stream = document.getElementById('msgStream');
        if (stream) stream.scrollTop = stream.scrollHeight;
    };
</script>
</body>
</html>