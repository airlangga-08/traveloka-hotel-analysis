CREATE DATABASE milestone_2;
DROP TABLE traveloka_raw;
CREATE TABLE traveloka_raw(time_collacted timestamp,
	 city VARCHAR (50),
	 checkin TEXT,
	 checkout TEXT,
	 num_staying_nights INT,
	 id BIGINT,
	 name VARCHAR (300),
	 displayName VARCHAR(300),
	 region VARCHAR (300),
	 starRating FLOAT,
	 userRating FLOAT,
	 numReviews FLOAT,
	 userRatingInfo VARCHAR (300),
	 latitude FLOAT,
	 longitude FLOAT,
	 lowRate INT,
	 highRate FLOAT,
	 hotelFeatures TEXT,
	 hotelSeoUrl TEXT,
	 cheapestRate_allNights_baseFare INT,
	 cheapestRate_allNights_fees INT,
	 cheapestRate_allNights_taxes FLOAT,
	 cheapestRate_allNights_totalFare INT,
	 cheapestRate_perNight_baseFare INT,
	 cheapestRate_perNight_fees FLOAT,
	 cheapestRate_perNight_taxes FLOAT,
	 cheapestRate_perNight_totalFare INT,
	 originalRate_allNights_baseFare INT,
	 originalRate_allNights_fees INT,
	 originalRate_allNights_taxes INT,
	 originalRate_allNights_totalFare INT,
	 originalRate_perNight_baseFare INT,
	 originalRate_perNight_fees FLOAT,
	 originalRate_perNight_taxes FLOAT,
	 originalRate_perNight_totalFare INT	 
);
Copy traveloka_raw
FROM 'C:\Users\Airlangga\Downloads\traveloka_newyearhotels.csv'
DELIMITER '|' CSV HEADER;

SELECT * FROM traveloka_raw;