package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

	private static final String ORACLE_DRIVER = "oracle.jdbc.driver.OracleDriver"; 
	private static final String ORACLE_URL = "jdbc:oracle:thin:@//localhost:1521/freepdb1"; 
	private static final String ORACLE_USER = "KINDERGARTEN"; 
	private static final String ORACLE_PASS = "system";    
	
	
	public static Connection getConnection() throws SQLException, ClassNotFoundException {
		Class.forName(ORACLE_DRIVER);
		
		// Return the database connection
		return DriverManager.getConnection(ORACLE_URL, ORACLE_USER, ORACLE_PASS);
	}
}