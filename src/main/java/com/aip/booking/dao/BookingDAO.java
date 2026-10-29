
package com.aip.booking.dao;

import com.aip.booking.Booking;
import com.aip.booking.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    // CREATE: Add a booking
    public boolean addBooking(Booking b) throws SQLException {

        String sql = "INSERT INTO bookings "
                + "(organizer, room_name, booking_date, "
                + "start_time, end_time, purpose) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, b.organizer);
            ps.setString(2, b.roomName);
            ps.setString(3, b.bookingDate);
            ps.setString(4, b.startTime);
            ps.setString(5, b.endTime);
            ps.setString(6, b.purpose);

            return ps.executeUpdate() > 0;
        }
    }

    // READ: Get all bookings
    public List<Booking> getAllBookings() throws SQLException {

        List<Booking> bookings = new ArrayList<>();

        String sql = "SELECT * FROM bookings "
                + "ORDER BY booking_date, start_time";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Booking b = new Booking();

                b.id = rs.getInt("id");
                b.organizer = rs.getString("organizer");
                b.roomName = rs.getString("room_name");
                b.bookingDate = rs.getString("booking_date");
                b.startTime = rs.getString("start_time");
                b.endTime = rs.getString("end_time");
                b.purpose = rs.getString("purpose");

                bookings.add(b);
            }
        }

        return bookings;
    }

    // UPDATE: Edit a booking
    public boolean updateBooking(Booking b) throws SQLException {

        String sql = "UPDATE bookings SET organizer=?, room_name=?, "
                + "booking_date=?, start_time=?, end_time=?, purpose=? "
                + "WHERE id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, b.organizer);
            ps.setString(2, b.roomName);
            ps.setString(3, b.bookingDate);
            ps.setString(4, b.startTime);
            ps.setString(5, b.endTime);
            ps.setString(6, b.purpose);
            ps.setInt(7, b.id);

            return ps.executeUpdate() > 0;
        }
    }

    // DELETE: Remove a booking
    public boolean deleteBooking(int id) throws SQLException {

        String sql = "DELETE FROM bookings WHERE id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        }
    }

    // CHECK: Prevent overlapping bookings for the same room and date
    public boolean hasOverlappingBooking(
            String roomName,
            String bookingDate,
            String startTime,
            String endTime,
            int excludeId) throws SQLException {

        String sql = "SELECT COUNT(*) FROM bookings "
                + "WHERE room_name = ? "
                + "AND booking_date = ? "
                + "AND start_time < ? "
                + "AND end_time > ? "
                + "AND id <> ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, roomName);
            ps.setString(2, bookingDate);
            ps.setString(3, endTime);
            ps.setString(4, startTime);
            ps.setInt(5, excludeId);

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }
}
