# Database Access Instructions 

## In the Model Page...

### Step1: Defining the Page Model Class
```c
public class WeeklyViewModel : PageModel
{
    public List<TimeSlot> TimeSlots { get; set; } = new List<TimeSlot>();
```

-   **WeeklyViewModel**: This is a `PageModel` class that acts as the code-behind for a Razor Page. It holds logic for data retrieval and defines properties to be used in the Razor Page.

### Step2: Handling GET Requests
```
public void OnGet()
{
    LoadCurrentWeekTimeSlots();
}
```

- **OnGet**: This method is executed when the page is accessed with a GET request. Here, it calls `LoadCurrentWeekTimeSlots`, which loads time slot data for the current week

### Step 3: Acc DB Access

**a) First set the connection string where you need to access the DB**
```
private void LoadCurrentWeekTimeSlots()
{
    string connectionString = "server=127.0.0.1;user=root;password=Kiav@z1208;database=seniordesignproject;";

```
-   **connectionString**: Defines the details for connecting to the MySQL database. You should replace it with secure credentials as needed.

**b) Then get the stuNetID from the Session (so we get the right students data**
```
    string stuNetID = HttpContext.Session.GetString("StudentNetId");

    if (string.IsNullOrEmpty(stuNetID))
    {
        Console.WriteLine("Error: StudentNetId not found in session.");
        return;
    }

```

**c) Connecting to the Database:**
``` 
    using (var connection = new MySqlConnection(connectionString))
    {
        connection.Open();
```

- **Connection**: Opens a connection to the MySQL database. The `using` statement ensures the connection is closed and disposed after this block completes.

**d)  Setting Up the MySQL Command and Parameters**

```
        using (var cmd = new MySqlCommand("student_timeslot_by_week", connection))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@stu_netID", stuNetID);
            cmd.Parameters.AddWithValue("@start_date", startDate);
```

-   **MySQL Command**: Defines a command that calls the `student_timeslot_by_week` stored procedure in the MySQL database.
-   **CommandType**: Specifies that this command is a stored procedure.
-   **Parameters**: Adds two parameters:
    -   `@stu_netID`: The student’s ID.
    -   `@start_date`: The start date for the week.

**e) Executing the Command and Reading Data**
```
            using (var reader = cmd.ExecuteReader())
            {
                Console.WriteLine("Executing stored procedure: student_timeslot_by_week for current week with stuNetID: " + stuNetID);

                while (reader.Read())
                {
                    string durationString = reader.GetString(4);
                    string[] timeParts = durationString.Split(':');
                    int hours = int.Parse(timeParts[0]);
                    int minutes = int.Parse(timeParts[1]);
                    int totalMinutes = (hours * 60) + minutes;

```
- **ExecuteReader**: Executes the command and retrieves data in the form of a `MySqlDataReader`.


## In the CSHTML Page (View)

### Step 1: Declaring the Page Model
```
@page
@model WeeklyViewModel

```

###  Step2: Access values from the model
```
var entriesForDay = Model.TimeSlots.Where(ts => ts.TSDate.Date == day.Date).ToList();
```
- Basically whatever attributes are defined in the Model Class can be accessed in the CSHTML file in a similar manor. 
- For this example, in WholeProjectViewModel.cs we had:
	```
	public List<TimeSlot> TimeSlots { get; set; } =  new List<TimeSlot>(); 
	``` 



