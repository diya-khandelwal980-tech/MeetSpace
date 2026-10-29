
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.aip.booking.Booking" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>

<%
    List<Booking> bookings =
        (List<Booking>) request.getAttribute("bookings");

    int total = bookings == null ? 0 : bookings.size();
    int roomA = 0, roomB = 0, roomC = 0;
    int todayCount = 0;
    int upcomingCount = 0;

    LocalDate today = LocalDate.now();

    if (bookings != null) {
        for (Booking b : bookings) {
            if (b.roomName != null) {
                String room = b.roomName.toLowerCase();

                if (room.contains("conference room a")) roomA++;
                else if (room.contains("conference room b")) roomB++;
                else if (room.contains("meeting room c")) roomC++;
            }

            try {
                LocalDate date = LocalDate.parse(b.bookingDate);
                if (date.equals(today)) todayCount++;
                if (!date.isBefore(today)) upcomingCount++;
            } catch (Exception ignored) {}
        }
    }

    int maxRoomCount = Math.max(1, Math.max(roomA, Math.max(roomB, roomC)));
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MeetSpace | Your Meeting Hub</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/style.css">

    <style>
        /* Dashboard widgets and interactions */
        .extra-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px;
            margin: 22px 0;
        }

        .widget {
            background: var(--widget-bg, #fffaf8);
            border: 1px solid #f0e2e7;
            border-radius: 22px;
            padding: 22px;
            box-shadow: 0 8px 25px rgba(130, 87, 105, .06);
        }

        .widget h3 { margin: 0 0 7px; }
        .muted { color: #8c7b85; font-size: 13px; }
        .clock-time { font-size: 29px; font-weight: 750; margin: 12px 0 4px; }
        .clock-date { color: #8c7b85; }

        .room-bar { margin-top: 17px; }
        .room-bar-label {
            display: flex; justify-content: space-between;
            font-size: 13px; margin-bottom: 7px;
        }
        .bar-track {
            background: #f5e9ed; height: 10px;
            border-radius: 20px; overflow: hidden;
        }
        .bar-fill {
            height: 100%; border-radius: 20px;
            transition: width .4s ease;
        }
        .fill-a { background: #e9a5b8; }
        .fill-b { background: #b6a6df; }
        .fill-c { background: #9dc7ad; }

        .widget-number { font-size: 32px; font-weight: 750; margin: 10px 0 2px; }
        .widget-emoji { font-size: 25px; margin-bottom: 8px; }

        .toolbar-controls {
            display: flex; flex-wrap: wrap; gap: 10px;
            align-items: center; margin: 16px 0;
        }
        .toolbar-controls input, .toolbar-controls select {
            min-width: 150px; flex: 1; padding: 11px 13px;
            border: 1px solid #ead9e0; border-radius: 12px;
            background: #fffdfc; color: #594753;
            font: inherit; outline-color: #d99bb0;
        }

        .soft-button {
            border: 1px solid #ebd4df; border-radius: 12px;
            padding: 10px 14px; background: #fff0f5;
            color: #87566b; cursor: pointer; font: inherit;
            font-weight: 650; text-decoration: none;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .soft-button:hover { background: #f9dfe9; transform: translateY(-1px); }
        .soft-button.selected { background: #e9dff8; border-color: #d2c0ef; }

        .meeting-cards {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 13px; margin-top: 15px;
        }
        .meeting-card {
            padding: 16px; border-radius: 16px;
            background: #fff5f7; border: 1px solid #f0dfe5;
        }
        .meeting-card:nth-child(3n + 2) { background: #f6f1ff; }
        .meeting-card:nth-child(3n) { background: #f0f8f2; }
        .meeting-card strong { display: block; margin-bottom: 8px; }
        .meeting-card p { margin: 5px 0; font-size: 13px; }
        .meeting-card .meeting-time { color: #98627b; font-weight: 700; }

        .calendar-day {
            border: 1px solid #efdee5; border-radius: 15px;
            padding: 14px; margin: 10px 0; background: #fffdfc;
        }
        .calendar-day h4 { margin: 0 0 10px; color: #96627a; }
        .calendar-event {
            padding: 10px 12px; margin: 7px 0;
            border-radius: 10px; background: #f8e8ee;
            font-size: 13px;
        }
        .calendar-event:nth-child(even) { background: #eee8fa; }

        .empty-widget {
            padding: 24px; text-align: center;
            color: #907e89; background: #fff8fa;
            border-radius: 15px;
        }
        .hidden-view { display: none !important; }

        .panel-heading { gap: 16px; flex-wrap: wrap; }
        .topbar-right { display: flex; align-items: center; gap: 8px; }

        @media (max-width: 760px) {
            .extra-grid { grid-template-columns: 1fr; }
            .toolbar-controls { align-items: stretch; }
            .toolbar-controls input, .toolbar-controls select { min-width: 100%; }
        }
    </style>
</head>

<body class="dashboard-body">

<div class="topbar">
    <div class="brand">
        <span class="brand-icon">🎀</span>
        <span>MeetSpace</span>
    </div>
    <div class="topbar-right">
        <span class="status-dot"></span>
        Your little meeting hub
    </div>
</div>

<div class="dashboard-layout">
    <aside class="sidebar">
        <p class="sidebar-label">YOUR WORKSPACE</p>

        <a class="nav-link active"
           href="${pageContext.request.contextPath}/bookings">
            <span>🏠</span> Dashboard
        </a>

        <a class="nav-link" href="#bookings">
            <span>📋</span> All Bookings
        </a>

        <a class="nav-link"
           href="${pageContext.request.contextPath}/booking-form.jsp">
            <span>➕</span> Add Booking
        </a>

        <button class="nav-link" type="button" id="themeToggle"
                style="width:100%;border:0;cursor:pointer;text-align:left;">
            <span>🌙</span> Toggle Theme
        </button>

        <div class="sidebar-bottom">
            <div class="sidebar-mini-icon">🌷</div>
            <strong>Small plans, big things.</strong>
            <p>Make room for great ideas.</p>
        </div>
    </aside>

    <main class="main-content">

        <section class="welcome-section">
            <div class="welcome-text">
                <span class="eyebrow">A LITTLE SPACE TO DO GREAT THINGS</span>
                <h1>Hey there, planner! ✨</h1>
                <p>Your meetings, your rooms, your schedule — all in one place.</p>
                <a class="primary-button"
                   href="${pageContext.request.contextPath}/booking-form.jsp">
                    ＋ Create a Booking
                </a>
            </div>
            <div class="welcome-art">
                <div class="art-calendar">🗓️</div>
                <div class="art-title">Plan. Meet. Bloom.</div>
                <div class="art-subtitle">One meeting at a time ♡</div>
            </div>
        </section>

        <section class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue-icon">📋</div>
                <div>
                    <p class="stat-label">Total Bookings</p>
                    <h2><%= total %></h2>
                    <p class="stat-note">All saved reservations</p>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon green-icon">🌞</div>
                <div>
                    <p class="stat-label">Today's Meetings</p>
                    <h2><%= todayCount %></h2>
                    <p class="stat-note">Scheduled for today</p>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon purple-icon">🌷</div>
                <div>
                    <p class="stat-label">Upcoming</p>
                    <h2><%= upcomingCount %></h2>
                    <p class="stat-note">Today and future dates</p>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon orange-icon">🏡</div>
                <div>
                    <p class="stat-label">Rooms in Use</p>
                    <h2><%= (roomA > 0 ? 1 : 0) + (roomB > 0 ? 1 : 0) + (roomC > 0 ? 1 : 0) %></h2>
                    <p class="stat-note">Rooms with saved bookings</p>
                </div>
            </div>
        </section>

        <section class="extra-grid">
            <div class="widget">
                <div class="widget-emoji">⏰</div>
                <h3>Your local time</h3>
                <div class="clock-time" id="liveClock">--:--:--</div>
                <div class="clock-date" id="liveDate">Loading date...</div>
                <p class="muted">A little reminder to take a breath between meetings.</p>
            </div>

            <div class="widget">
                <div class="widget-emoji">🌸</div>
                <h3>Room usage</h3>
                <p class="muted">Number of saved bookings by room</p>

                <div class="room-bar">
                    <div class="room-bar-label">
                        <span>Conference Room A</span><strong><%= roomA %></strong>
                    </div>
                    <div class="bar-track">
                        <div class="bar-fill fill-a"
                             style="width:<%= roomA * 100 / maxRoomCount %>%"></div>
                    </div>
                </div>

                <div class="room-bar">
                    <div class="room-bar-label">
                        <span>Conference Room B</span><strong><%= roomB %></strong>
                    </div>
                    <div class="bar-track">
                        <div class="bar-fill fill-b"
                             style="width:<%= roomB * 100 / maxRoomCount %>%"></div>
                    </div>
                </div>

                <div class="room-bar">
                    <div class="room-bar-label">
                        <span>Meeting Room C</span><strong><%= roomC %></strong>
                    </div>
                    <div class="bar-track">
                        <div class="bar-fill fill-c"
                             style="width:<%= roomC * 100 / maxRoomCount %>%"></div>
                    </div>
                </div>
                <p class="muted">Counts reflect saved bookings, not room capacity.</p>
            </div>
        </section>

        <section class="widget">
            <h3>💌 Coming up</h3>
            <p class="muted">Your next meetings, sorted by date and start time.</p>
            <div id="upcomingMeetings" class="meeting-cards"></div>
        </section>

        <section class="bookings-panel" id="bookings">
            <div class="panel-heading">
                <div>
                    <span class="eyebrow">YOUR SCHEDULE</span>
                    <h2>All Bookings 🌷</h2>
                    <p>Search, filter, switch views, or export your bookings.</p>
                </div>
                <a class="primary-button"
                   href="${pageContext.request.contextPath}/booking-form.jsp">
                    ＋ Add Booking
                </a>
            </div>

            <div class="toolbar-controls">
                <input type="search" id="bookingSearch"
                       placeholder="🔎 Search organizer, room or purpose...">

                <select id="roomFilter" aria-label="Filter by room">
                    <option value="">All rooms</option>
                    <option value="conference room a">Conference Room A</option>
                    <option value="conference room b">Conference Room B</option>
                    <option value="meeting room c">Meeting Room C</option>
                </select>

                <input type="date" id="dateFilter" aria-label="Filter by date">

                <button class="soft-button selected" id="listViewButton" type="button">
                    ☷ List
                </button>
                <button class="soft-button" id="calendarViewButton" type="button">
                    🗓 Calendar
                </button>
                <button class="soft-button" id="exportButton" type="button">
                    ↓ Export CSV
                </button>
            </div>

            <div class="muted" id="resultCount">
                Showing <%= total %> booking(s)
            </div>

            <div class="table-wrapper" id="tableView">
                <table class="booking-table" id="bookingTable">
                    <thead>
                        <tr>
                            <th>ID</th><th>Organizer</th><th>Meeting Room</th>
                            <th>Date</th><th>Start Time</th><th>End Time</th>
                            <th>Purpose</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (bookings != null && !bookings.isEmpty()) {
                           for (Booking b : bookings) { %>
                        <tr data-id="<%= b.id %>"
                            data-organizer="<%= b.organizer == null ? "" : b.organizer %>"
                            data-room="<%= b.roomName == null ? "" : b.roomName %>"
                            data-date="<%= b.bookingDate == null ? "" : b.bookingDate %>"
                            data-start="<%= b.startTime == null ? "" : b.startTime %>"
                            data-end="<%= b.endTime == null ? "" : b.endTime %>"
                            data-purpose="<%= b.purpose == null ? "" : b.purpose %>">

                            <td><span class="id-badge">#<%= b.id %></span></td>
                            <td class="organizer-cell">
                                <span class="avatar"><%= b.organizer != null && !b.organizer.isEmpty()
                                    ? b.organizer.substring(0, 1).toUpperCase() : "?" %></span>
                                <%= b.organizer %>
                            </td>
                            <td><%= b.roomName %></td>
                            <td><span class="date-badge"><%= b.bookingDate %></span></td>
                            <td><%= b.startTime %></td>
                            <td><%= b.endTime %></td>
                            <td><%= b.purpose %></td>
                            <td class="action-cell">
                                <a class="edit-button"
                                   href="${pageContext.request.contextPath}/bookings?action=edit&id=<%= b.id %>">Edit</a>
                                <a class="delete-button"
                                   href="${pageContext.request.contextPath}/bookings?action=delete&id=<%= b.id %>"
                                   onclick="return confirm('Delete this booking?');">Delete</a>
                            </td>
                        </tr>
                    <%     }
                       } else { %>
                        <tr><td colspan="8" class="empty-state">
                            <div class="empty-icon">🗓️</div>
                            <strong>No bookings yet</strong>
                            <p>Your first booking will show up here.</p>
                        </td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div id="calendarView" class="hidden-view"></div>

            <p class="table-footer">MeetSpace · Made for better meetings ♡</p>
        </section>

        <footer class="dashboard-footer">
            <span>MeetSpace · Meeting Room Booking System</span>
            <span>Java · JSP · Servlets · MySQL</span>
        </footer>
    </main>
</div>

<script>
    const rows = Array.from(document.querySelectorAll(
        "#bookingTable tbody tr[data-id]"
    ));

    const searchInput = document.getElementById("bookingSearch");
    const roomFilter = document.getElementById("roomFilter");
    const dateFilter = document.getElementById("dateFilter");
    const tableView = document.getElementById("tableView");
    const calendarView = document.getElementById("calendarView");
    const listButton = document.getElementById("listViewButton");
    const calendarButton = document.getElementById("calendarViewButton");
    const resultCount = document.getElementById("resultCount");

    function updateClock() {
        const now = new Date();
        document.getElementById("liveClock").textContent =
            now.toLocaleTimeString([], {
                hour: "2-digit", minute: "2-digit", second: "2-digit"
            });
        document.getElementById("liveDate").textContent =
            now.toLocaleDateString([], {
                weekday: "long", year: "numeric",
                month: "long", day: "numeric"
            });
    }
    updateClock();
    setInterval(updateClock, 1000);

    function getRowData(row) {
        return {
            id: row.dataset.id,
            organizer: row.dataset.organizer || "",
            room: row.dataset.room || "",
            date: row.dataset.date || "",
            start: row.dataset.start || "",
            end: row.dataset.end || "",
            purpose: row.dataset.purpose || ""
        };
    }

    const allBookings = rows.map(getRowData);

    function getFilteredBookings() {
        const query = searchInput.value.trim().toLowerCase();
        const room = roomFilter.value.toLowerCase();
        const date = dateFilter.value;

        return allBookings.filter(b => {
            const searchable = [
                b.id, b.organizer, b.room, b.date,
                b.start, b.end, b.purpose
            ].join(" ").toLowerCase();

            return searchable.includes(query)
                && (!room || b.room.toLowerCase().includes(room))
                && (!date || b.date === date);
        });
    }

    function escapeHtml(value) {
        return String(value).replace(/[&<>"']/g, ch => ({
            "&": "&amp;", "<": "&lt;", ">": "&gt;",
            '"': "&quot;", "'": "&#39;"
        }[ch]));
    }

    function renderCalendar(bookings) {
        if (bookings.length === 0) {
            calendarView.innerHTML =
                '<div class="empty-widget">No bookings match your filters 🌷</div>';
            return;
        }

        const groups = {};
        bookings.sort((a, b) =>
            (a.date + a.start).localeCompare(b.date + b.start)
        ).forEach(b => {
            if (!groups[b.date]) groups[b.date] = [];
            groups[b.date].push(b);
        });

        calendarView.innerHTML = Object.keys(groups).map(date => {
            const readableDate = new Date(date + "T12:00:00")
                .toLocaleDateString([], {
                    weekday: "long", month: "short",
                    day: "numeric", year: "numeric"
                });

            const events = groups[date].map(b =>
                '<div class="calendar-event">' +
                '<strong>' + escapeHtml(b.start) + '–' + escapeHtml(b.end) +
                '</strong> · ' + escapeHtml(b.room) +
                '<br>' + escapeHtml(b.organizer) +
                ' — ' + escapeHtml(b.purpose) + '</div>'
            ).join("");

            return '<div class="calendar-day"><h4>♡ ' +
                escapeHtml(readableDate) + '</h4>' + events + '</div>';
        }).join("");
    }

    function applyFilters() {
        const filtered = getFilteredBookings();
        const visibleIds = new Set(filtered.map(b => b.id));

        rows.forEach(row => {
            row.style.display = visibleIds.has(row.dataset.id) ? "" : "none";
        });

        resultCount.textContent =
            "Showing " + filtered.length + " of " + allBookings.length + " booking(s)";

        renderCalendar(filtered);
        renderUpcoming();
    }

    function renderUpcoming() {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const upcoming = allBookings.filter(b => {
            if (!b.date) return false;
            const date = new Date(b.date + "T00:00:00");
            return date >= today;
        }).sort((a, b) =>
            (a.date + a.start).localeCompare(b.date + b.start)
        ).slice(0, 4);

        const container = document.getElementById("upcomingMeetings");

        if (upcoming.length === 0) {
            container.innerHTML =
                '<div class="empty-widget">Nothing coming up yet. Enjoy the breathing room! ☁️</div>';
            return;
        }

        container.innerHTML = upcoming.map(b =>
            '<div class="meeting-card">' +
            '<strong>🌷 ' + escapeHtml(b.room) + '</strong>' +
            '<p>👤 ' + escapeHtml(b.organizer) + '</p>' +
            '<p>📅 ' + escapeHtml(b.date) + '</p>' +
            '<p class="meeting-time">⏰ ' +
            escapeHtml(b.start) + ' – ' + escapeHtml(b.end) + '</p>' +
            '<p>💌 ' + escapeHtml(b.purpose) + '</p>' +
            '</div>'
        ).join("");
    }

    [searchInput, roomFilter, dateFilter].forEach(control =>
        control.addEventListener("input", applyFilters)
    );

    listButton.addEventListener("click", () => {
        tableView.classList.remove("hidden-view");
        calendarView.classList.add("hidden-view");
        listButton.classList.add("selected");
        calendarButton.classList.remove("selected");
    });

    calendarButton.addEventListener("click", () => {
        tableView.classList.add("hidden-view");
        calendarView.classList.remove("hidden-view");
        calendarButton.classList.add("selected");
        listButton.classList.remove("selected");
        renderCalendar(getFilteredBookings());
    });

    document.getElementById("exportButton").addEventListener("click", () => {
        const filtered = getFilteredBookings();
        const headers = ["ID", "Organizer", "Room", "Date",
                         "Start Time", "End Time", "Purpose"];

        const csvCell = value =>
            '"' + String(value).replace(/"/g, '""') + '"';

        const csv = [headers, ...filtered.map(b => [
            b.id, b.organizer, b.room, b.date,
            b.start, b.end, b.purpose
        ])].map(line => line.map(csvCell).join(",")).join("\r\n");

        const blob = new Blob(["\uFEFF" + csv], {
            type: "text/csv;charset=utf-8;"
        });
        const url = URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.href = url;
        link.download = "meetspace-bookings.csv";
        link.click();
        URL.revokeObjectURL(url);
    });

    document.getElementById("themeToggle").addEventListener("click", () => {
        document.body.classList.toggle("dark-dashboard");
        const dark = document.body.classList.contains("dark-dashboard");
        document.getElementById("themeToggle").innerHTML =
            dark ? "<span>☀️</span> Light Theme" :
                   "<span>🌙</span> Toggle Theme";
    });

    applyFilters();
</script>

</body>
</html>
