
package com.aip.booking;

import com.aip.booking.dao.BookingDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/bookings")
public class BookingServlet extends HttpServlet {

    private BookingDAO dao;

    @Override
    public void init() {
        dao = new BookingDAO();
    }

    // READ, EDIT FORM, DELETE
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.deleteBooking(id);

                response.sendRedirect(
                        request.getContextPath() + "/bookings");
                return;
            }

            if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));

                List<Booking> bookings = dao.getAllBookings();

                for (Booking b : bookings) {
                    if (b.id == id) {
                        request.setAttribute("booking", b);
                        request.getRequestDispatcher(
                                "/booking-form.jsp").forward(request, response);
                        return;
                    }
                }

                response.sendRedirect(
                        request.getContextPath() + "/bookings");
                return;
            }

            request.setAttribute("bookings", dao.getAllBookings());
            request.getRequestDispatcher("/bookings.jsp")
                    .forward(request, response);

        } catch (SQLException | NumberFormatException e) {
            throw new ServletException("Unable to process booking.", e);
        }
    }

    // CREATE AND UPDATE
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            String idValue = request.getParameter("id");
            String organizer = request.getParameter("organizer");
            String roomName = request.getParameter("roomName");
            String bookingDate = request.getParameter("bookingDate");
            String startTime = request.getParameter("startTime");
            String endTime = request.getParameter("endTime");
            String purpose = request.getParameter("purpose");

            int id = (idValue == null || idValue.trim().isEmpty())
                    ? 0 : Integer.parseInt(idValue);

            // Basic validation
            if (organizer == null || roomName == null
                    || bookingDate == null || startTime == null
                    || endTime == null || purpose == null
                    || organizer.trim().isEmpty()
                    || roomName.trim().isEmpty()
                    || bookingDate.trim().isEmpty()
                    || startTime.trim().isEmpty()
                    || endTime.trim().isEmpty()
                    || purpose.trim().isEmpty()) {

                request.setAttribute("error",
                        "Please fill in all fields.");
                showForm(request, response, id);
                return;
            }

            // End time must be after start time
            if (startTime.compareTo(endTime) >= 0) {
                request.setAttribute("error",
                        "End time must be later than start time.");
                showForm(request, response, id);
                return;
            }

            // Prevent overlapping bookings
            boolean conflict = dao.hasOverlappingBooking(
                    roomName, bookingDate, startTime, endTime, id);

            if (conflict) {
                request.setAttribute("error",
                        "Oops! This room is already booked during "
                        + "that time. Please choose another time.");
                showForm(request, response, id);
                return;
            }

            // Create or update booking
            Booking b = new Booking();
            b.id = id;
            b.organizer = organizer.trim();
            b.roomName = roomName;
            b.bookingDate = bookingDate;
            b.startTime = startTime;
            b.endTime = endTime;
            b.purpose = purpose.trim();

            if (id > 0) {
                dao.updateBooking(b);
            } else {
                dao.addBooking(b);
            }

            response.sendRedirect(
                    request.getContextPath() + "/bookings");

        } catch (SQLException | NumberFormatException e) {
            throw new ServletException("Unable to save booking.", e);
        }
    }

    // Show form again if validation fails
    private void showForm(HttpServletRequest request,
                          HttpServletResponse response,
                          int id)
            throws ServletException, IOException {

        if (id > 0) {
            Booking b = new Booking();
            b.id = id;
            b.organizer = request.getParameter("organizer");
            b.roomName = request.getParameter("roomName");
            b.bookingDate = request.getParameter("bookingDate");
            b.startTime = request.getParameter("startTime");
            b.endTime = request.getParameter("endTime");
            b.purpose = request.getParameter("purpose");

            request.setAttribute("booking", b);
        }

        request.getRequestDispatcher("/booking-form.jsp")
                .forward(request, response);
    }
}
