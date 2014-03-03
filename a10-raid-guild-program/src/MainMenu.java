import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.sql.Statement;
import java.util.InputMismatchException;
import java.util.Scanner;
import com.mysql.jdbc.exceptions.jdbc4.MySQLIntegrityConstraintViolationException;

/**
 * JDBC Application for interfacing
 * with the Guild Raid Request MYSql Database.
 * 
 * CECS 323 - SPRING 2013
 * 
 * @authors Aaron Gutierrez
 * 			Israel Torres
 * 			Brandon Whitney
 */

public class MainMenu {
	
	/**
	 * User input and DB Driver Fields
	 */

	static Scanner scan = new Scanner(System.in);
	private String username;
	private String password;

	private final static String DB_DRIVER = "com.mysql.jdbc.Driver";
	private final static String DB_URL = "jdbc:mysql://127.0.0.1:3306/cecs323m11";
	private Connection conn;
	public static Savepoint save; // The sole savepoint used by the program.
								 // This will be updated on every commit and
							    // rollback

	/**
	 * ==================================================================
	 * Helper Queries
	 * Used to display tables and guide user interaction
	 * ==================================================================
	 **/
	private final static String SQL_FIND_ALL_ITEMS = "SELECT * "
			+ "FROM items ";

	private final static String ITEM_COUNT = "SELECT c.name, COUNT(i.itemID) "
			+ "FROM characters c "
			+ "LEFT OUTER JOIN characterItems ci ON c.characterID=ci.characterID "
			+ "LEFT OUTER JOIN items i ON ci.itemID=i.itemID "
			+ "GROUP BY c.name;";

	private final static String SHOW_GUILDS = "SELECT guildId, guildName FROM guilds ORDER BY guildId ASC;";
	private final static String SHOW_PLAYERS = "SELECT playerId, fName, lName FROM players ORDER BY playerId ASC;";
	private final static String SHOW_RAIDS = "SELECT raidId, name FROM raids ORDER BY raidId ASC;";

	private final static String DELETE_WARNING = "WARNING: Removing this player from the database will also "
			+ "remove all this player's characters and raid requests. "
			+ "If characters are removed, their associated "
			+ "items and stats will be lost as well. ";

	/**
	 * Main Menu
	 * @param args
	 * @throws SQLException
	 * @throws ClassNotFoundException
	 */
	public static void main(String[] args) throws SQLException,
			ClassNotFoundException {

		MainMenu menu = new MainMenu();

		boolean shouldDisplayMenu = true;
		String menuInput = "";
		int queryInput = 0;

		menu.sqlSetup();

		do {
			if (shouldDisplayMenu) {
				menu.displayMenu();
				shouldDisplayMenu = false;
			}
			try {
				menuInput = scan.next().toLowerCase();
			} catch (InputMismatchException ime) {
				System.out.println("Please enter a valid menu choice. ");
			}

			switch (menuInput) {

			case "query":
				System.out.println("Please select a query from the following list: ");
				System.out.println("1. List the amount of items every character has. \n"
								+ "2. Show the highest level character in a selected guild. \n"
								+ "3. Show all raids that a selected guild has requested at least once. \n");
				try {
					queryInput = scan.nextInt();

				} catch (InputMismatchException ime) {
					System.out.println("Please enter a valid menu choice. ");
				} 
				switch (queryInput) {
				case 1:
					menu.ItemCount();
					break;
				case 2:
					menu.HighestLevel();
					break;
				case 3:
					menu.RequestCount();
					break;
				}
				break;

			case "insert":
				System.out.println("You will be submitting a request to complete a raid with a chosen guild. \n");
				menu.insertRow();
				break;

			case "delete":
				System.out.println("You will be removing a player from the database. \n");
				menu.deleteRow();
				break;

			case "commit":
				System.out.println("Changes made to the database have been saved! \n");
				menu.commitChanges();
				break;

			case "rollback":
				System.out.println("Changes made to the database since the last commit have been deleted! \n");
				menu.rollbackChanges();
				break;

			case "help":
				shouldDisplayMenu = true;
				break;
				
			default: 
				System.out.println("Please enter a valid menu option. ");
				shouldDisplayMenu = true;
				break;

			case "quit":
				System.out.println("Would you like to commit or rollback before quitting? \n y/n");
				try {
					menuInput = scan.next();
				} catch(InputMismatchException ime) {
					System.out.println("Please enter a valid selection. ");
				}
				if (isResponseYes(menuInput)) {
					System.out.println("Please enter either 'rollback' or 'commit'. ");
					try {
						menuInput = scan.next();
					} catch(InputMismatchException ime) {
						System.out.println("Please enter a valid selection");
					}
					
					if (menuInput.equalsIgnoreCase("commit")) {
						System.out.println("Committing changes, closing connection to the database, and exiting the program...");
						menu.commitChanges();
						menu.conn.close();
						System.exit(0);
					} else if (menuInput.equalsIgnoreCase("rollback")) {
						menu.rollbackChanges();
						menu.conn.close();
						System.out.println("Removing changes, closing connection to the database, and exiting the program...");
						System.exit(0);
					} else {
						System.out.println("Invalid selection. Returning to main menu. ");
						shouldDisplayMenu = true;
					}
				} else if (menuInput.equalsIgnoreCase("n")) {
					System.out.println("Closing connection to the database and exiting the program...");
					menu.conn.close();
					System.exit(0);
				}
			}
		} 
		while (!menuInput.equalsIgnoreCase("quit"));
	}
	
	/**
	 * Setup Method
	 * @throws SQLException
	 * @throws ClassNotFoundException
	 */

	public void sqlSetup() throws SQLException, ClassNotFoundException {
		DriverManager.registerDriver(new com.mysql.jdbc.Driver());
		Class.forName(DB_DRIVER);
		System.out.println("Once you log in, you will be able to query or edit the database.");
		System.out.println("Enter your username");
		username = scan.next();
		System.out.println("Enter your password");
		password = scan.next();
		conn = DriverManager.getConnection(DB_URL, username, password);
		conn.setAutoCommit(false);
		save = conn.setSavepoint();
	}

	/**
	 * Query Methods
	 * @throws SQLException
	 */
	public void insertRow() throws SQLException {
		int guildChoice = 0;
		int raidChoice = 0;
		int playerChoice = 0;
		try {
			System.out.println("Please choose a guild to submit your request to. ");
			displayGuilds();
			try {
				guildChoice = scan.nextInt();
			} catch(InputMismatchException ime) {
				System.out.println("Please enter a valid selection. ");
			}
			System.out.println("Please choose the raid you want to complete. ");
			displayRaids();
			try {
				raidChoice = scan.nextInt();
			} catch(InputMismatchException ime) {
				System.out.println("Please enter a valid selection. ");
			}
			System.out.println("Please choose the player that will carry out your request. ");
			displayPlayers();
			try {
				playerChoice = scan.nextInt();
			} catch(InputMismatchException ime) {
				System.out.println("Please enter a valid selection. ");
			}
			String INSERT_REQUEST = "INSERT INTO requests "
					+ "(dateRequested, guild, raid, player, notes)"
					+ " VALUES ('2013-12-09'," + guildChoice + "," + raidChoice
					+ "," + playerChoice + ",'Guest Insert into Table')";

			Statement st = conn.createStatement();
			System.out.println("Rows inserted "
					+ st.executeUpdate(INSERT_REQUEST));
			st.close();
		} catch (MySQLIntegrityConstraintViolationException ice) {
			System.out.println("Cannot process insert. The Referential Integrity Constraint is violated. "
							+ "A player, guild, or raid that does not exist in the database has been chosen. ");
		}
	}

	public void deleteRow() throws SQLException {
		System.out.println("Please select one of the following players to be removed from the database. ");
		displayPlayers();
		int playerChoice = 0;
		try {
			playerChoice = scan.nextInt();
		} catch(InputMismatchException ime) {
			System.out.println("Please enter a valid selection. ");
		}
		String INTEGRITY_TEST_QUERY = "SELECT * " + "FROM players p "
				+ "INNER JOIN characters c ON p.playerId=c.player "
				+ "WHERE playerId =" + playerChoice;
		Statement test = conn.createStatement();
		ResultSet testResults = test.executeQuery(INTEGRITY_TEST_QUERY);
		if (testResults.next() == false) {
			System.out.println("No errors, removing player. ");
			deleteQuery(playerChoice);
		} else {
			System.out.println(DELETE_WARNING);
			System.out.println("Would you like to delete anyway? \n y/n");
			if(isResponseYes(scan.next())) {
				deleteQuery(playerChoice);
			} else {
				System.out.println("Delete aborted, returning to menu...");
			}
		}
		testResults.close();
		test.close();
	}
	
	public void deleteQuery(int c) throws SQLException {
		String DELETE_REQUEST = "DELETE from players "
				+ "WHERE playerId = " + c;
		Statement st = conn.createStatement();
		System.out.println("Rows deleted "
				+ st.executeUpdate(DELETE_REQUEST));
		st.close();
	}

	public void DisplayAllItems() throws SQLException {

		Statement st = conn.createStatement();
		ResultSet rs = st.executeQuery(SQL_FIND_ALL_ITEMS);
		while (rs.next())
			System.out.println(rs.getString(1) + " - " + rs.getString(2) + " - "
					+ rs.getString(3));
		rs.close();
		st.close();
	}

	public void displayGuilds() throws SQLException {
		Statement prest = conn.createStatement();
		System.out.println("Guild ID - Guild Name");
		ResultSet prers = prest.executeQuery(SHOW_GUILDS);

		while (prers.next())
			System.out.println(prers.getString(1) + " - " + prers.getString(2));
		prers.close();
		prest.close();
	}

	public void displayRaids() throws SQLException {
		Statement prest = conn.createStatement();
		System.out.println("Raid ID - Raid Name");
		ResultSet prers = prest.executeQuery(SHOW_RAIDS);

		while (prers.next())
			System.out.println(prers.getString(1) + " - " + prers.getString(2));
		prers.close();
		prest.close();
	}

	public void displayPlayers() throws SQLException {
		Statement prest = conn.createStatement();
		System.out.println("Player ID - Player Name");
		ResultSet prers = prest.executeQuery(SHOW_PLAYERS);

		while (prers.next())
			System.out.println(prers.getString(1) + " - " + prers.getString(2));
		prers.close();
		prest.close();
	}

	public void HighestLevel() throws SQLException {

		System.out.println("Please select a guild ID from the list");
		displayGuilds();
		int guildChoice = 0;
		try {
			guildChoice = scan.nextInt();
		} catch(InputMismatchException ime) {
			System.out.println("Please enter a valid selection. ");
		}
		String HIGHEST_LEVEL_IN_GUILD = "SELECT p.fName, p.lName, "
				+ "c.name, c.characterLevel " + "FROM players p "
				+ "INNER JOIN characters c ON c.player=p.playerId "
				+ "INNER JOIN guilds g ON c.guild=g.guildId "
				+ "WHERE g.guildId=" + guildChoice
				+ " AND c.characterLevel >= ALL "
				+ "(SELECT c1.characterLevel " + "FROM characters c1 "
				+ "INNER JOIN guilds g1 ON c1.guild=g1.guildId "
				+ "WHERE g1.guildId=" + guildChoice + ");";

		Statement st = conn.createStatement();
		ResultSet rs = st.executeQuery(HIGHEST_LEVEL_IN_GUILD);
		System.out.println("First Name - Last Name - Character Name - Level");
		while (rs.next())
			System.out.println(rs.getString(1) + " - " + rs.getString(2) + " - "
					+ rs.getString(3) + " - " + rs.getString(4));
		rs.close();
		st.close();
	}

	public void ItemCount() throws SQLException {

		Statement st = conn.createStatement();
		ResultSet rs = st.executeQuery(ITEM_COUNT);
		System.out.println("Name - Number of Items");
		while (rs.next())
			System.out.println(rs.getString(1) + " - " + rs.getString(2));
		rs.close();
		st.close();
	}

	public void RequestCount() throws SQLException {

		Statement prest = conn.createStatement();
		ResultSet prers = prest.executeQuery(SHOW_GUILDS);
		System.out.println("Please select a guild ID from the list");
		while (prers.next())
			System.out.println(prers.getString(1) + " - " + prers.getString(2));
		prers.close();
		prest.close();
		
		int guildChoice = 0;
		try {
			guildChoice = scan.nextInt();
			String NUM_REQUESTS = "SELECT ra.name, COUNT(re.guild) FROM requests re "
					+ "INNER JOIN raids ra ON re.raid=ra.raidID "
					+ "INNER JOIN guilds g on re.guild=g.guildID "
					+ "WHERE g.guildId="
					+ guildChoice
					+ " "
					+ "GROUP BY ra.name HAVING COUNT(re.guild) >= 1;";

			Statement st = conn.createStatement();
			ResultSet rs = st.executeQuery(NUM_REQUESTS);
			System.out.println("Raid - Number of times Requested");
			while (rs.next())
				System.out.println(rs.getString(1) + " - " + rs.getString(2));
			rs.close();
			st.close();
		} catch(InputMismatchException ime) {
			System.out.println("Please enter a valid selection. ");
		}
	}

	/**
	 * Commit/Rollback/Misc Methods
	 **/
	public void commitChanges() {
		try {
			save = conn.setSavepoint();
			conn.commit();
		} catch (SQLException sqle) {
			System.out.println("There was an error committing the changes to the database. ");
		}
	}

	public void rollbackChanges() {
		try {
			conn.rollback(save);
			save = conn.setSavepoint();
		} catch (SQLException sqle) {
			System.out.println("There was an error rolling back the changes to the database. ");
		}
	}
	
	public void displayMenu() {
		System.out.println("Type one of the following: \n"
				+ "query: to query the databse \n"
				+ "insert: to insert a row to a table \n"
				+ "delete: to delete a row from a table \n"
				+ "commit: to save changes to the database \n"
				+ "rollback: to remove changes from the database \n"
				+ "help: to display the menu options \n"
				+ "quit: to exit the program \n");
	}
	/**
	 * Borrowed from the JDBC Sample Application
	 * by Professor Monge
	 * @param userResponse
	 * @return boolean
	 */
	public static boolean isResponseYes(String userResponse) {
		boolean result = false;
		if (null != userResponse) {
			char firstCharacter = userResponse.charAt(0);
			if (firstCharacter == 'y' || firstCharacter == 'Y') {
				result = true;
			}
		}

		return result;
	}
}
