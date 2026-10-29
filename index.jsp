<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="false"
    import="java.io.*,java.util.*" %>
<%
    // Read each line as a question and its correct answer.
    ArrayList<String[]> questions = new ArrayList<String[]>();
    try (BufferedReader reader = new BufferedReader(new InputStreamReader(
            application.getResourceAsStream("/assignment.txt"), "UTF-8"))) {
        String line;
        while ((line = reader.readLine()) != null) {
            questions.add(line.split("#"));
        }
    }

    // Count correct answers when the form is submitted.
    boolean submitted = "POST".equals(request.getMethod());
    int score = 0;
    if (submitted) {
        for (int i = 0; i < questions.size(); i++) {
            String answer = request.getParameter("answer" + i);
            if (questions.get(i)[1].trim().equals(answer)) {
                score++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Online Exam</title>
</head>
<body>
    <h2>Online Exam</h2>
    <form action="index.jsp" method="post">
        <table>
        <% for (int i = 0; i < questions.size(); i++) { %>
            <tr>
                <td><%= questions.get(i)[0] %></td>
                <td><label><input type="radio" name="answer<%= i %>" value="true" required>True</label></td>
                <td><label><input type="radio" name="answer<%= i %>" value="false" required>False</label></td>
            </tr>
        <% } %>
            <tr>
                <td></td>
                <td colspan="2"><input type="submit" value="Submit"></td>
            </tr>
        </table>
    </form>

    <% if (submitted) { %>
        <p>Total Marks: <%= score %> / 10</p>
    <% } %>
</body>
</html>
