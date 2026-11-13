<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Chat"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
    List<Chat> chatHistory = (List<Chat>) request.getAttribute("chatHistory");
    List<HashMap<String, Object>> contactList = (List<HashMap<String, Object>>) request.getAttribute("contactList");

    String currentRole = (request.getAttribute("senderRole") != null)
                         ? request.getAttribute("senderRole").toString()
                         : "Parent";
    boolean isTeacherView = "Teacher".equalsIgnoreCase(currentRole);

    int activeParentID = (request.getAttribute("parentID") != null) ? (int) request.getAttribute("parentID") : 0;
    int activeTeacherID = (request.getAttribute("teacherID") != null) ? (int) request.getAttribute("teacherID") : 0;

    String pName = (request.getAttribute("parentName") != null && !request.getAttribute("parentName").toString().isEmpty())
                   ? request.getAttribute("parentName").toString()
                   : (session.getAttribute("parentName") != null ? session.getAttribute("parentName").toString() : "Parent");
    String tName = (request.getAttribute("teacherName") != null && !request.getAttribute("teacherName").toString().isEmpty())
                   ? request.getAttribute("teacherName").toString()
                   : (session.getAttribute("teacherName") != null ? session.getAttribute("teacherName").toString() : "Teacher");

    String activeChatPartner = isTeacherView ? pName : tName;
    String activePartnerBadge = isTeacherView ? "Parent / Guardian" : "Teacher";
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parent-Teacher Hub - Keedflix Centre</title>

    <style>
        :root {
            --bg-canvas: #FAF5EF;
            --border-dark: #2D3436;
            --yellow-accent: #FFD166;
            --coral-accent: #FF6B6B;
            --mint-accent: #2EC4B6;
            --purple-accent: #7C3AED;
            --purple-bg: #F3E8FF;
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
            padding: 24px 28px;
            overflow-y: auto;
        }

        /* MAIN HUB CONTAINER */
        .nb-hub-card {
            max-width: 1200px;
            margin: 0 auto;
            background-color: #FFFFFF;
            border: 3px solid var(--border-dark);
            border-radius: 26px;
            box-shadow: var(--shadow-lg);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: 700px;
        }

        /* TOP YELLOW BANNER */
        .hub-top-banner {
            background-color: var(--yellow-accent);
            border-bottom: 3px solid var(--border-dark);
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }

        .hub-icon-box {
            width: 44px;
            height: 44px;
            background: #FFFFFF;
            border: 2px solid var(--border-dark);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            box-shadow: var(--shadow-sm);
            flex-shrink: 0;
        }

        .student-context-pill {
            background: #FFFFFF;
            border: 2px solid var(--border-dark);
            border-radius: 16px;
            padding: 8px 16px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 0.82rem;
            font-weight: 800;
            box-shadow: var(--shadow-md);
        }

        /* WORKSPACE SPLIT */
        .chat-workspace {
            display: flex;
            flex-grow: 1;
            overflow: hidden;
        }

        /* LEFT SIDEBAR */
        .chat-sidebar {
            width: 310px;
            flex-shrink: 0;
            border-right: 2px solid #E2E8F0;
            background: #FFFFFF;
            display: flex;
            flex-direction: column;
            padding: 16px;
            gap: 14px;
            overflow-y: auto;
        }

        .search-box-wrap {
            position: relative;
        }
        .search-input {
            width: 100%;
            padding: 10px 14px 10px 36px;
            background-color: #FAF5EF;
            border: 1.5px solid #E2E8F0;
            border-radius: 14px;
            font-size: 0.82rem;
            font-weight: 600;
            color: var(--border-dark);
            outline: none;
        }
        .search-input:focus {
            border-color: var(--border-dark);
            background: #FFFFFF;
        }
        .search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 0.85rem;
            color: #94A3B8;
        }

        .security-banner {
            background-color: #F0FDF9;
            border: 1px solid #CCFBF1;
            border-radius: 12px;
            padding: 10px 12px;
            font-size: 0.7rem;
            line-height: 1.4;
            color: #475569;
            display: flex;
            gap: 8px;
            align-items: flex-start;
        }

        .contact-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .contact-item {
            padding: 12px 14px;
            border-radius: 18px;
            border: 1.5px solid transparent;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .contact-item:hover {
            background-color: #F8FAFC;
        }
        .contact-item.active {
            background-color: #FFFFFF;
            border: 2px solid var(--border-dark);
            box-shadow: var(--shadow-md);
        }

        .contact-avatar {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            border: 1.5px solid #CBD5E1;
            background: #F8FAFC;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }
        .contact-item.active .contact-avatar {
            background: var(--yellow-accent);
            border: 2px solid var(--border-dark);
        }

        /* RIGHT MAIN CHAT AREA */
        .chat-main {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            background: #FFFFFF;
            min-width: 0;
        }

        .chat-header {
            padding: 14px 20px;
            border-bottom: 1.5px solid #E2E8F0;
            background: #FFFFFF;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-tools {
            display: flex;
            align-items: center;
            gap: 16px;
            color: #64748B;
            font-size: 1rem;
        }
        .header-tools span {
            cursor: pointer;
            transition: color 0.15s;
        }
        .header-tools span:hover {
            color: var(--border-dark);
        }

        .sim-banner {
            background-color: #F5F3FF;
            border-bottom: 1px solid #EDE9FE;
            padding: 8px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.72rem;
            flex-wrap: wrap;
            gap: 8px;
        }

        /* MESSAGE STREAM */
        .msg-stream {
            flex-grow: 1;
            padding: 20px 24px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 16px;
            background-color: #FFFDF9;
            background-image: radial-gradient(rgba(45, 52, 54, 0.1) 1.5px, transparent 1.5px);
            background-size: 18px 18px;
        }

        .msg-group {
            display: flex;
            flex-direction: column;
            max-width: 72%;
        }
        .msg-group.own {
            align-self: flex-end;
            align-items: flex-end;
        }
        .msg-group.other {
            align-self: flex-start;
            align-items: flex-start;
        }

        .msg-sender-label {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 0.68rem;
            font-weight: 700;
            color: #64748B;
            margin-bottom: 4px;
            padding: 0 4px;
        }

        .msg-bubble {
            padding: 14px 18px;
            border-radius: 18px;
            font-size: 0.85rem;
            font-weight: 500;
            line-height: 1.5;
            position: relative;
            width: 100%;
        }
        .msg-own {
            background-color: var(--purple-bg);
            border: 1.5px solid #8B5CF6;
            border-top-right-radius: 4px;
            color: #1E293B;
        }
        .msg-other {
            background-color: #FFFFFF;
            border: 1.5px solid #CBD5E1;
            border-top-left-radius: 4px;
            color: #1E293B;
        }

        .msg-meta {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 0.65rem;
            color: #64748B;
            margin-top: 8px;
            text-align: right;
            font-weight: 600;
        }

        /* QUICK TEMPLATES BAR */
        .quick-templates-bar {
            padding: 10px 20px;
            background: #FFFFFF;
            border-top: 1px solid #F1F5F9;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .template-pill {
            background: #FFFFFF;
            border: 1.5px solid #CBD5E1;
            border-radius: 999px;
            padding: 6px 14px;
            font-size: 0.74rem;
            font-weight: 700;
            color: var(--border-dark);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.15s ease;
        }
        .template-pill:hover {
            border-color: var(--border-dark);
            background-color: #FAF5EF;
            transform: translateY(-1px);
        }

        /* BOTTOM INPUT BAR */
        .chat-input-form {
            padding: 12px 20px 16px 20px;
            background: #FFFFFF;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .input-action-icons {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #64748B;
            font-size: 1.1rem;
        }
        .input-action-icons span {
            cursor: pointer;
        }

        .chat-text-input {
            flex-grow: 1;
            padding: 12px 18px;
            background-color: #FAF5EF;
            border: 1.5px solid #E2E8F0;
            border-radius: 16px;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--border-dark);
            outline: none;
        }
        .chat-text-input:focus {
            background-color: #FFFFFF;
            border-color: var(--border-dark);
        }

        .send-icon-btn {
            width: 44px;
            height: 44px;
            background-color: #FDE68A;
            border: 2px solid var(--border-dark);
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: all 0.15s ease;
            flex-shrink: 0;
        }
        .send-icon-btn:hover {
            background-color: var(--yellow-accent);
            transform: translate(-1px, -1px);
            box-shadow: var(--shadow-md);
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
            <div class="nb-hub-card">

                <!-- TOP YELLOW HEADER -->
                <div class="hub-top-banner">
                    <div style="display: flex; align-items: center; gap: 14px;">
                        <div class="hub-icon-box">💬</div>
                        <div>
                            <h2 style="font-size: 1.25rem; font-weight: 900; letter-spacing: -0.3px;">Parent-Teacher Hub</h2>
                            <p style="font-size: 0.78rem; font-weight: 600; color: #334155;">
                                Komunikasi langsung antara guru dan penjaga berkaitan pembelajaran murid
                            </p>
                        </div>
                    </div>

                    <div class="student-context-pill">
                        <span style="background: #FEF3C7; padding: 3px 6px; border-radius: 8px; border: 1px solid #F59E0B;">🦁</span>
                        <span>Murid: ${not empty studentName ? studentName : 'Tiada Rekod'}</span>
                        <span style="color: #94A3B8;">·</span>
                        <span style="color: #64748B; font-weight: 700;">${not empty studentClass ? studentClass : '-'}</span>
                    </div>
                </div>

                <div class="chat-workspace">

                    <!-- LEFT CONTACTS SIDEBAR -->
                    <div class="chat-sidebar">
                        <div class="search-box-wrap">
                            <span class="search-icon">🔍</span>
                            <input type="text" class="search-input" id="chatSearchInput" placeholder="Search chats..." onkeyup="filterContacts()">
                        </div>

                        <div class="security-banner">
                            <span style="color: #0D9488; font-size: 0.9rem;">🛡️</span>
                            <div>
                                <strong style="color: #0F766E;">End-to-End Secure:</strong> All data is fully protected and adheres strictly to school privacy agreements.
                            </div>
                        </div>

                        <div class="contact-list" id="contactList">
                            <%
                                if (contactList != null && !contactList.isEmpty()) {
                                    for (HashMap<String, Object> contact : contactList) {
                                        int cId = (int) contact.get("id");
                                        String cName = (String) contact.get("name");
                                        String cSub = (String) contact.get("subtitle");
                                        boolean isActiveContact = isTeacherView ? (cId == activeParentID) : (cId == activeTeacherID);
                                        String targetUrl = isTeacherView
                                            ? ("ChatServlet?parentID=" + cId + "&teacherID=" + activeTeacherID + "&senderRole=Teacher")
                                            : ("ChatServlet?parentID=" + activeParentID + "&teacherID=" + cId + "&senderRole=Parent");
                            %>
                                        <a href="<%= targetUrl %>" style="text-decoration: none; color: inherit;">
                                            <div class="contact-item <%= isActiveContact ? "active" : "" %>">
                                                <div style="display: flex; align-items: center; gap: 12px; min-width: 0;">
                                                    <div class="contact-avatar"><%= isTeacherView ? "👪" : "👩‍🏫" %></div>
                                                    <div style="min-width: 0;">
                                                        <h4 style="font-size: 0.82rem; font-weight: 900; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                            <%= cName %>
                                                        </h4>
                                                        <p style="font-size: 0.7rem; color: #64748B; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                            <%= cSub %>
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                        </a>
                            <%
                                    }
                                } else {
                            %>
                                    <div class="contact-item active">
                                        <div style="display: flex; align-items: center; gap: 12px; min-width: 0;">
                                            <div class="contact-avatar"><%= isTeacherView ? "👪" : "👩‍🏫" %></div>
                                            <div style="min-width: 0;">
                                                <h4 style="font-size: 0.82rem; font-weight: 900;"><%= activeChatPartner %></h4>
                                                <p style="font-size: 0.7rem; color: #64748B; font-weight: 700;">Active Now</p>
                                            </div>
                                        </div>
                                    </div>
                            <%
                                }
                            %>
                        </div>
                    </div>

                    <!-- RIGHT CONVERSATION AREA -->
                    <div class="chat-main">

                        <!-- Active Chat Header -->
                        <div class="chat-header">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 38px; height: 38px; background: var(--yellow-accent); border: 2px solid var(--border-dark); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                                    <%= isTeacherView ? "👪" : "👩‍🏫" %>
                                </div>
                                <div>
                                    <h4 style="font-size: 0.92rem; font-weight: 900;">
                                        <%= activeChatPartner %> (<%= activePartnerBadge %>)
                                    </h4>
                                    <div style="font-size: 0.72rem; color: #10B981; font-weight: 800; display: flex; align-items: center; gap: 5px;">
                                        <span style="width: 7px; height: 7px; background: #10B981; border-radius: 50%; display: inline-block;"></span>
                                        Online
                                    </div>
                                </div>
                            </div>

                            <div class="header-tools">
                                <span title="Audio">🔊</span>
                                <span style="color: #CBD5E1;">|</span>
                                <span title="Voice Call">📞</span>
                                <span title="Video Call">📹</span>
                                <span title="More Options">⋮</span>
                            </div>
                        </div>

                        <!-- Sub-Header Strip -->
                        <div class="sim-banner">
                            <span style="color: #6D28D9; font-weight: 800;">
                                ✨ Direct messaging with <%= activeChatPartner %>!
                            </span>
                            <span style="color: #64748B; font-weight: 600;">
                                Select quick templates below to ask questions!
                            </span>
                        </div>

                        <!-- MESSAGE STREAM -->
                        <div class="msg-stream" id="msgStream">
                            <%
                                SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");

                                if (chatHistory != null && !chatHistory.isEmpty()) {
                                    for (Chat chat : chatHistory) {
                                        String msgRole = (chat.getSenderRole() != null) ? chat.getSenderRole() : "Parent";
                                        boolean isOwn = msgRole.equalsIgnoreCase(currentRole);
                                        String displaySender = "parent".equalsIgnoreCase(msgRole) ? pName : (tName + " (Teacher)");
                                        String formattedTime = (chat.getSentDateTime() != null) ? timeFmt.format(chat.getSentDateTime()) : "";
                            %>
                                        <div class="msg-group <%= isOwn ? "own" : "other" %>">
                                            <div class="msg-sender-label"><%= displaySender %></div>
                                            <div class="msg-bubble <%= isOwn ? "msg-own" : "msg-other" %>">
                                                <div><%= chat.getMessageContent() %></div>
                                                <div class="msg-meta">
                                                    <%= formattedTime %>
                                                    <% if (isOwn) { %>
                                                        <span style="font-weight: 900; margin-left: 4px; color: <%= chat.isRead() ? "#2563EB" : "#94A3B8" %>;"
                                                              title="<%= chat.isRead() ? "Dibaca" : "Dihantar" %>">✓✓</span>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                            <%
                                    }
                                } else {
                            %>
                                    <div style="text-align: center; color: #94A3B8; font-size: 0.8rem; font-weight: 700; margin-top: 40px;">
                                        Tiada rekod perbualan lagi. Mulakan mesej anda di bawah!
                                    </div>
                            <%
                                }
                            %>
                        </div>

                        <!-- QUICK TEMPLATES -->
                        <div class="quick-templates-bar">
                            <% if (isTeacherView) { %>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Selamat sejahtera, anak anda menunjukkan peningkatan yang sangat baik dalam kelas hari ini!')">
                                    🌟 Kongsi Pencapaian Murid
                                </button>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Sila semak modul Learning Progress untuk laporan pentaksiran mingguan terkini.')">
                                    📊 Maklum Laporan Mingguan
                                </button>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Terima kasih atas kerjasama pihak ibu bapa dalam memantau latihan di rumah.')">
                                    🤝 Penghargaan Penjaga
                                </button>
                            <% } else { %>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Ask about Math progress: How is my child doing in counting activities this week?')">
                                    📊 Ask about Math progress
                                </button>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Ask about Pencil Grip: Has there been improvement in tripod grip during writing?')">
                                    ✏️ Ask about Pencil Grip
                                </button>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Thank you teacher for the detailed update and guidance!')">
                                    ❤️ Send Encouragement
                                </button>
                            <% } %>
                        </div>

                        <!-- BOTTOM FORM -->
                        <form action="${pageContext.request.contextPath}/ChatServlet" method="POST" class="chat-input-form">
                            <input type="hidden" name="parentID" value="<%= activeParentID %>">
                            <input type="hidden" name="teacherID" value="<%= activeTeacherID %>">
                            <input type="hidden" name="senderRole" value="<%= isTeacherView ? "Teacher" : "Parent" %>">

                            <div class="input-action-icons">
                                <span title="Emoji">😊</span>
                                <span title="Attach File">📎</span>
                            </div>

                            <input type="text" name="messageContent" id="messageInput" class="chat-text-input" 
                                   placeholder="Type a message as <%= isTeacherView ? "Teacher" : "Parent" %>..." required autocomplete="off">
                            
                            <button type="submit" class="send-icon-btn" title="Hantar Mesej">
                                ➤
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
        const input = document.getElementById('messageInput');
        input.value = text;
        input.focus();
    }

    function filterContacts() {
        const query = document.getElementById('chatSearchInput').value.toLowerCase();
        document.querySelectorAll('#contactList a').forEach(item => {
            const text = item.innerText.toLowerCase();
            item.style.display = text.includes(query) ? 'block' : 'none';
        });
    }

    window.onload = function() {
        var stream = document.getElementById('msgStream');
        if (stream) stream.scrollTop = stream.scrollHeight;
    };
</script>
</body>
</html>