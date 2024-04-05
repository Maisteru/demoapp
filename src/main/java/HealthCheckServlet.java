import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class HealthCheckServlet extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Ustaw typ zawartości odpowiedzi
        response.setContentType("text/plain");

        // Wyślij prostą odpowiedź wskazującą, że serwer działa
        PrintWriter out = response.getWriter();
        out.print("OK");
    }
}