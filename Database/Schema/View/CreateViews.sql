-- Drop all views

DROP VIEW vwPresenters;
DROP VIEW vwSchedule;
DROP VIEW vwPresentations;
DROP VIEW vwSponsors;
DROP VIEW vwPresentationSubjectLocation;


-- Create all views

-- View to display all persons that have the presenter role
CREATE VIEW vwPresenters
  AS (
  SELECT p.idPerson, p.firstName, p.lastName FROM Person p
    WHERE idPerson IN
          (SELECT idPerson FROM RolesPersonMapping rpm
          WHERE p.idPerson = rpm.idPerson AND rpm.idRole = (SELECT idRole FROM PersonRole WHERE role = 'Presenter')
          )
);

-- View to display all scheduled presentations with their event, room number, and scheduled time
CREATE VIEW vwSchedule
  AS (
    SELECT p.title, st.scheduleTime, e.eventName, r.roomNumber FROM PresentationSchedule ps
      INNER JOIN Presentation p ON ps.idPresentation = p.idPresentation
      INNER JOIN ScheduleTime st ON ps.idScheduleTime = st.idScheduleTime
      INNER JOIN Event e ON ps.idEvent = e.idEvent
      INNER JOIN Room r ON ps.idRoom = r.idRoom

);

-- View to display all presentations, their presenter, and whether they are scheduled or not
CREATE VIEW vwPresentations
  AS (
    SELECT ppm.idPresentation, pr.title, pe.firstName, pe.lastName, pl.level,
      (SELECT CASE WHEN ps.idSchedule IS NULL THEN 'False' ELSE 'True' END) AS scheduled
    FROM PresentationPresenterMapping ppm
      INNER JOIN Person pe ON ppm.idPresenter = pe.idPerson
      INNER JOIN Presentation pr ON ppm.idPresentation = pr.idPresentation
      INNER JOIN PresentationLevel pl ON pr.idLevel = pl.idLevel
      LEFT JOIN PresentationSchedule ps ON ps.idPresentation = ppm.idPresentation
);

-- View to display all sponsors and their corresponding sponsor level
CREATE VIEW vwSponsors
  AS (
    SELECT s.sponsorName, sl.sponsorLevel FROM Sponsor s INNER JOIN SponsorLevel sl ON s.idSponsorLevel = sl.idSponsorLevel
);

-- View to display all scheduled presentations, their subject, and their event location
CREATE VIEW vwPresentationSubjectLocation
  AS (
    SELECT p.title, t.subject, (SELECT eventLocation FROM Event e WHERE e.idEvent = ps.idEvent) eventLocation FROM PresentationTrackMapping ptm
      INNER JOIN Presentation p ON ptm.idPresentation = p.idPresentation
      INNER JOIN Track t ON ptm.idTrack = t.idTrack
      INNER JOIN PresentationSchedule ps ON ptm.idPresentation = ps.idPresentation
      WHERE EXISTS(SELECT 1 FROM PresentationSchedule ps WHERE ps.idPresentation = ptm.idPresentation)
);