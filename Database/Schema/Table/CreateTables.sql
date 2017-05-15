-- Drop all tables

DROP TABLE RolesPersonMapping;
DROP TABLE PresentationTrackMapping;
DROP TABLE PresentationPresenterMapping;
DROP TABLE PresentationSchedule;
DROP TABLE Sponsor;

DROP TABLE Presentation;
DROP TABLE Room;
DROP TABLE Vendor;
DROP TABLE Booth;

DROP TABLE PersonRole;
DROP TABLE Person;
DROP TABLE PresentationLevel;
DROP TABLE Event;
DROP TABLE Track;
DROP TABLE ScheduleTime;
DROP TABLE SponsorLevel;


-- Create all tables

CREATE TABLE PersonRole(
  idRole int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  role varchar(45) NOT NULL UNIQUE
);
INSERT INTO PersonRole VALUES
  ('Presenter'),
  ('Volunteer'),
  ('Sponsor'),
  ('Vendor'),
  ('Student'),
  ('Attendee'),
  ('Organizer');


CREATE TABLE Person(
  idPerson int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  firstName varchar(35) NOT NULL,
  lastName varchar(35) NOT NULL,
  street varchar(255),
  city varchar(90),
  postalCode varchar(10),
  country varchar(90),
  emailAddress varchar(255) NOT NULL UNIQUE DEFAULT NEWID(),
  phoneNumber varchar(50) NOT NULL UNIQUE DEFAULT NEWID()
);


CREATE TABLE RolesPersonMapping(
  idPerson int NOT NULL  FOREIGN KEY REFERENCES Person(idPerson),
  idRole int NOT NULL FOREIGN KEY REFERENCES PersonRole(idRole),
  CONSTRAINT rolePerson UNIQUE (
    idPerson,
    idRole
  )
);


CREATE TABLE PresentationLevel(
  idLevel int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  level varchar(45) NOT NULL UNIQUE
);
INSERT INTO PresentationLevel VALUES
  ('Non-Technical'),
  ('Beginner'),
  ('Intermediate'),
  ('Advanced');


CREATE TABLE Presentation(
  idPresentation int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  title varchar(255) NOT NULL,
  description varchar(255),
  idLevel int NOT NULL FOREIGN KEY REFERENCES PresentationLevel(idLevel)
);


CREATE TABLE Event(
  idEvent int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  eventDate DATE NOT NULL,
  eventName VARCHAR(255) NOT NULL UNIQUE,
  eventLocation VARCHAR(255) NOT NULL,
  eventRegion VARCHAR(255),
  numRooms int NOT NULL
);


CREATE TABLE Room(
  idRoom int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  roomNumber int NOT NULL,
  idEvent int NOT NULL FOREIGN KEY REFERENCES Event(idEvent),
  CONSTRAINT eventRoom UNIQUE (
    roomNumber,
    idEvent
  )
);


CREATE TABLE Booth(
  idBooth int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  boothNumber int NOT NULL,
  idEvent int NOT NULL FOREIGN KEY REFERENCES Event(idEvent),
  CONSTRAINT boothEvent UNIQUE (
    boothNumber,
    idEvent
  )
);


CREATE TABLE Vendor(
  idVendor int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  name varchar(255) NOT NULL,
  idBooth int NOT NULL FOREIGN KEY REFERENCES Booth(idBooth)
);


CREATE TABLE Track(
  idTrack int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  subject varchar(45) NOT NULL UNIQUE
);
INSERT INTO Track VALUES
  ('Application And Database Development'),
  ('Analytics And Visualization'),
  ('Advanced Analysis Techniques'),
  ('Cloud Application Development'),
  ('Enterprise Database Administration');


CREATE TABLE PresentationTrackMapping(
  idPresentation int NOT NULL FOREIGN KEY REFERENCES Presentation(idPresentation),
  idTrack int NOT NULL FOREIGN KEY REFERENCES Track(idTrack),
  CONSTRAINT PresentationTrack UNIQUE (
    idPresentation,
    idTrack
  )
);


CREATE TABLE ScheduleTime(
  idScheduleTime INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  scheduleTime TIME NOT NULL UNIQUE
);
INSERT INTO ScheduleTime (scheduleTime) VALUES
  ('8:00'),
  ('9:00'),
  ('10:00'),
  ('11:00'),
  ('12:00'),
  ('13:00'),
  ('14:00'),
  ('15:00'),
  ('16:00'),
  ('17:00'),
  ('18:00');


CREATE TABLE PresentationSchedule(
  idSchedule int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  idRoom int NOT NULL FOREIGN KEY REFERENCES Room(idRoom),
  idEvent int NOT NULL FOREIGN KEY REFERENCES Event(idEvent),
  idPresentation INT NOT NULL FOREIGN KEY REFERENCES Presentation(idPresentation),
  idScheduleTime INT NOT NULL FOREIGN KEY REFERENCES ScheduleTime(idScheduleTime),
  CONSTRAINT scheduleEvent UNIQUE (
    idRoom,
    idEvent,
    idScheduleTime
  )
);


CREATE TABLE PresentationPresenterMapping(
  idPresentation int NOT NULL FOREIGN KEY REFERENCES Presentation(idPresentation),
  idPresenter int NOT NULL FOREIGN KEY REFERENCES Person(idPerson),
  CONSTRAINT PresentationPresenter UNIQUE (
    idPresentation,
    idPresenter
  )
);


CREATE TABLE SponsorLevel(
  idSponsorLevel int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  sponsorLevel VARCHAR(255) NOT NULL
);
INSERT INTO SponsorLevel VALUES
  ('Bronze Sponsor'),
  ('Silver Sponsor'),
  ('Gold Sponsor'),
  ('Platinum Sponsor');


CREATE TABLE Sponsor(
  idSponsor int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
  sponsorName VARCHAR(255) NOT NULL UNIQUE,
  idSponsorLevel INT NOT NULL FOREIGN KEY REFERENCES SponsorLevel(idSponsorLevel)
);