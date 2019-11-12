import utilities.*;
import java.sql.*;
import org.apache.ibatis.jdbc.ScriptRunner;
import java.io.*;

public class TestSchemaCreation {
	public static void main(String[] args) throws SQLException, FileNotFoundException {
		String userWindows = System.getenv("HMSPATH");
		FileReader pathSchema = new FileReader(userWindows + "sql/createSchema.sql");

		FileReader pathTriggers = new FileReader(userWindows + "sql/triggerAutoIncrement.sql");

		CreateTables CT = new CreateTables();

		// CT.ClearDB();

		// CT.CreateTables(pathSchema);

		CT.ClearTriggers();

		CT.CreateTriggers(pathTriggers);
	}
}