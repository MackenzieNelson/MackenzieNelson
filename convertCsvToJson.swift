import Foundation

struct Exercise: Codable {
  var name: String
  var warmUpSets: String
  var workingSets: String
  var reps: String
  var load: String
  var rpe: String
  var rest: String
  var substitutions: [String]
  var notes: String
}

struct Day: Codable {
  var name: String = ""
  var exercises: [Exercise] = []
}

struct Week: Codable {
  var name: String = ""
  var days: [Day] = []
}

struct Root: Codable {
  var name: String = ""
  var weeks: [Week] = []
}

func main() {
  //Ask for path to file to parse
//  print("Please input path to file")
//  if let pathToFile = readLine() {
//    parseCSVToJSON(csvFilePath: pathToFile)
//  }
  parseCSVToJSON(csvFilePath: "/Users/mackenzienelson/Documents/The Essentials 4x Week.csv")
}

func parseCSVToJSON(csvFilePath: String) {
  var root = Root()
  var currentWeek: Week? = nil
  var currentDay: Day? = nil
  
  // Load the CSV file
  guard let csvContent = try? String(contentsOfFile: csvFilePath) else {
    print("Error loading CSV file.")
    return
  }
  let rows = csvContent.components(
    separatedBy: "\n"
  ).map{ $0.components(separatedBy: ",") }
  
  for row in rows {
    if row[1].isEmpty || row[0].lowercased().contains("rest day") {
      //When we hit an empty row, save current day
      if let currentDay {
        currentWeek?.days.append(currentDay)
      }
      currentDay = nil
    } else if row[0].lowercased().contains("week") {
      if row[0].lowercased().contains("program") {
        root.name = row[0]
        continue
      }
      // Create a new week
      if currentWeek == nil || currentWeek?.name != row[0] {
        //Save the week we just made, then overwrite it with the new week
        if let currentWeek {
          root.weeks.append(currentWeek)
        }
        currentWeek = Week(name: String(row[0]))
      }
            
    } else {
      // Skip empty exercise
      if String(row[1]).isEmpty { continue }
      // Process an exercise
      
      if currentDay == nil {
        currentDay = Day(name: String(row[0]))
      }
      
      let exercise = Exercise(
        name: String(row[1]),
        warmUpSets: String(row[2]),
        workingSets: String(row[3]),
        reps: String(row[4]),
        load: String(row[5]),
        rpe: String(row[6]) ,
        rest: String(row[7]),
        substitutions: [String(row[8]), String(row[9])],
        notes: String(row[10])
      )
      currentDay?.exercises.append(exercise)
    }
  }
  
//  // Finalize the last day and week
//  if let day = currentDay {
//    currentWeek?.days.append(day)
//  }
//  if let week = currentWeek {
//    root.weeks.append(week)
//  }
  
  // Save JSON to file
  let fileManager = FileManager.default
  
  // Get the current directory (or specify another directory)
  let currentDirectory = fileManager.currentDirectoryPath
  let outputFile = "\(currentDirectory)/JsonOutput"
  let encoder = JSONEncoder()
  encoder.outputFormatting = .prettyPrinted
  do {
    let jsonData = try encoder.encode(root)
    try jsonData.write(to: URL(fileURLWithPath: outputFile))
    print("JSON saved to \(outputFile)")
  } catch {
    print("Error saving JSON: \(error)")
  }
}


main()
