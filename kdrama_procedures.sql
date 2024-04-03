USE kdrama_schema;

DROP VIEW IF EXISTS View_ShowDetails;

CREATE VIEW View_ShowDetails AS
SELECT 
    s.ShowID,
    s.Name AS ShowName,
    s.NumOfEpisodes,
    s.Duration,
    s.ContentRating,
    s.Rating,
    c.Name AS CrewName,
    c.Title AS CrewTitle,
    a.AirDateStart,
    a.YearOfRelease,
    a.OriginalNetwork,
    a.AiredOn,
    a.AirDateEnd,
    g.GenreName,
    p.Name AS ProductionCompanyName
FROM 
    Shows s
    LEFT JOIN CrewToShow cts ON s.ShowID = cts.ShowID
    LEFT JOIN Crew c ON cts.CrewID = c.CrewID
    LEFT JOIN Airing a ON s.ShowID = a.ShowID
    LEFT JOIN GenreToShow gts ON s.ShowID = gts.ShowID
    LEFT JOIN Genre g ON gts.GenreID = g.GenreID
    LEFT JOIN ProductionToShow pts ON s.ShowID = pts.ShowID
    LEFT JOIN ProductionCompany p ON pts.CompanyID = p.CompanyID;
    
-- New table is a log of updates for trigger statement --
DROP TABLE IF EXISTS UpdateLog;
CREATE TABLE UpdateLog (
    LogID INT NOT NULL AUTO_INCREMENT,
    ShowID INT NOT NULL,
    PreviousNumOfEpisodes INT,
    NewNumOfEpisodes INT,
    UpdateTimestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (LogID),
    FOREIGN KEY (ShowID) REFERENCES Shows(ShowID)
);
DELIMITER $$

CREATE TRIGGER LogNumOfEpisodesUpdate
AFTER UPDATE ON Shows
FOR EACH ROW
BEGIN
    IF OLD.NumOfEpisodes <> NEW.NumOfEpisodes THEN
        INSERT INTO UpdateLog (ShowID, PreviousNumOfEpisodes, NewNumOfEpisodes)
        VALUES (NEW.ShowID, OLD.NumOfEpisodes, NEW.NumOfEpisodes);
    END IF;
END$$

DELIMITER ;
