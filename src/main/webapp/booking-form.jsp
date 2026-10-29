
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.aip.booking.Booking" %>

<%
    Booking booking = (Booking) request.getAttribute("booking");
    boolean editing = booking != null;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Meeting Room Booking</title>
<link rel="stylesheet"
      href="${pageContext.request.contextPath}/style.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f1f5f9;
            padding: 30px;
        }

        .container {
            max-width: 500px;
            margin: auto;
            background: white;
            padding: 25px;
            border-radius: 10px;
        }

        h1 {
            text-align: center;
            color: #1e293b;
        }

        label {
            display: block;
            margin-top: 14px;
        }

        input, select, textarea {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            box-sizing: border-box;
        }

        button {
            margin-top: 20px;
            padding: 12px;
            width: 100%;
            background: #2563eb;
            color: white;
            border: none;
            cursor: pointer;
        }

        a {
            display: block;
            margin-top: 15px;
            text-align: center;
        }
    </style>
</head>

<body>
<div class="container">

    <h1><%= editing ? "Edit Booking" : "Book a Meeting Room" %></h1>

    <form action="<%= request.getContextPath() %>/bookings"
          method="post">

        <input type="hidden" name="action"
               value="<%= editing ? "update" : "add" %>">

        <% if (editing) { %>
            <input type="hidden" name="id"
                   value="<%= booking.id %>">
        <% } %>

        <label>Organizer Name</label>
        <input type="text" name="organizer"
               value="<%= editing ? booking.organizer : "" %>"
               required>

        <label>Meeting Room</label>
        <select name="roomName" required>
            <option value="">Select a room</option>

            <option value="Conference Room A"
                <%= editing && "Conference Room A".equals(booking.roomName) ? "selected" : "" %>>
                Conference Room A
            </option>

            <option value="Conference Room B"
                <%= editing && "Conference Room B".equals(booking.roomName) ? "selected" : "" %>>
                Conference Room B
            </option>

            <option value="Meeting Room C"
                <%= editing && "Meeting Room C".equals(booking.roomName) ? "selected" : "" %>>
                Meeting Room C
            </option>
        </select>

        <label>Booking Date</label>
        <input type="date" name="bookingDate"
               value="<%= editing ? booking.bookingDate : "" %>"
               required>

        <label>Start Time</label>
        <input type="time" name="startTime"
               value="<%= editing ? booking.startTime : "" %>"
               required>

        <label>End Time</label>
        <input type="time" name="endTime"
               value="<%= editing ? booking.endTime : "" %>"
               required>

        <label>Purpose of Meeting</label>
        <textarea name="purpose" rows="3" required><%= editing ? booking.purpose : "" %></textarea>

        <button type="submit">
            <%= editing ? "Update Booking" : "Save Booking" %>
        </button>
    </form>

    <a href="<%= request.getContextPath() %>/bookings">
        View All Bookings
    </a>

</div>
</body>
</html>
