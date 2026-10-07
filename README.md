**_ServiceRun_**

**Project Overview**
ServiceRun is an iOS application designed for IT field technicians who travel between customer locations to install, diagnose, maintain, and repair equipment. The app gives technicians one place to manage scheduled visits, view site details, keep track of required tasks, record technician notes, and close a visit once all work has been completed.The idea behind ServiceRun is to make the field technician workflow easier to manage while travelling between jobs, especially when important information such as addresses, tasks, notes, and customer details may otherwise be spread across different systems or messages.

**Domain Context**
The main stakeholder is an IT field technician who regularly works at different customer sites. During a service visit, the technician needs quick access to the site details, a clear list of outstanding tasks, and a way to record what work was completed.
ServiceRun uses domain-specific terminology throughout the app, including service visits, visit tasks, technician notes, scheduled visits, completed visits, and visit history.

**Architecture**
ServiceRun uses a layered architecture to separate the user interface, business logic, and data storage.
The general structure is:
SwiftUI Views  
→ ViewModels  
→ Use Cases  
→ VisitRepository  
→ CoreDataVisitRepository  
→ Core Data
The use cases contain important business rules such as validating a service visit before it is scheduled, preventing blank task titles, requiring technician notes before completing a task, and preventing a visit from being closed while tasks are still incomplete.
The `VisitRepository` protocol separates the business logic from Core Data, which also makes the use cases easier to test using a mock repository.

**Core Data**
Core Data is used to persist the main domain data so that service visits and tasks remain available after the app is closed.
The database contains two related entities:
- `ServiceVisit`
- `VisitTask`
A service visit can contain multiple tasks, while each task belongs to a service visit. The repository also includes a query that retrieves incomplete visits scheduled for the current day and sorts them by scheduled time.
Core Data was chosen because the app mainly needs structured local storage that can work without relying on an internet connection.

**Widget Extension**
ServiceRun includes a WidgetKit extension that allows the technician to quickly view their next service visit from the Home Screen.
The widget displays information such as the next site, scheduled time, outstanding task count, and number of visits for the day. It supports both small and medium widget families.
The main app stores a small copy of the required widget data in the shared App Group and requests a widget timeline reload whenever relevant visit information changes.

**Share Extension**
The Share Extension allows text and web URLs to be shared into ServiceRun from other apps such as Safari.
When content is shared, the extension saves it into the shared App Group and dismisses correctly. When ServiceRun becomes active, the main app checks for the shared content and allows the technician to view it.
This is useful when a technician receives a site link or job information outside of ServiceRun and wants to quickly bring that information into the app.

**App Group**
The main app, Widget Extension, and Share Extension use the following App Group:
`group.com.kenneth.servicerun`
The App Group is used for communication between the app and its extensions, while the main service visit data remains stored in Core Data.

**Main Features**
ServiceRun supports:
- Scheduling service visits
- Viewing today's incomplete visits
- Viewing visit details
- Adding visit tasks
- Completing tasks with technician notes
- Closing completed visits
- Viewing visit history
- Sharing text and URLs into ServiceRun
- Viewing upcoming visit information through a Home Screen widget

**Testing**
The project includes five unit tests covering the main use cases. A `MockVisitRepository` is used instead of the real Core Data repository so the tests focus on business rules.
The tests cover successful behaviour, boundary conditions, and domain errors, including scheduling a valid visit, rejecting a missing site name, rejecting a blank task title, completing a task with technician notes, and preventing a visit from closing while tasks are incomplete.

**Setup**
Open KenServiceRun.xcodeproj in Xcode and select the KenServiceRun scheme with an iPhone Simulator.
Run the app using:
Command + R
Run the unit tests using:
Command + U
To test the widget, create a visit scheduled for the current day and add the ServiceRun widget to the simulator Home Screen.
To test the Share Extension, open Safari, share a webpage using the system share sheet, select the ServiceRun Share Extension, and then return to ServiceRun to view the shared content.

**Development**
The project was developed using separate Git branches for major features such as the Core Data model, main application workflow, Widget Extension, Share Extension, and unit testing. Stable features were merged back into the main branch after they were working correctly.

**Limitations**
ServiceRun is designed as a small single-technician application rather than a complete commercial field service platform. It does not currently include cloud synchronisation, multiple user accounts, remote job assignment, or live technician tracking. These features were kept outside the scope of the project so that the main workflow, persistence, extensions, architecture, and testing could be implemented clearly.
