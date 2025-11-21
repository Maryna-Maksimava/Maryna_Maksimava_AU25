

CREATE SCHEMA IF NOT EXISTS Political_campaign AUTHORIZATION CURRENT_USER;
SET search_path = Political_campaign, public;
--------------------------
CREATE TABLE IF NOT EXISTS Political_campaign.campaign (
    campaignid    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    candidate     VARCHAR(127) NOT NULL,
    startdate     DATE NOT NULL DEFAULT CURRENT_DATE,
    enddate       DATE,
    donationsgoal BIGINT NOT NULL DEFAULT 0,
    description   VARCHAR(255)
);
ALTER TABLE Political_campaign.campaign
  DROP CONSTRAINT IF EXISTS chk_campaign_startdate_after_2000;
ALTER TABLE Political_campaign.campaign
  ADD CONSTRAINT chk_campaign_startdate_after_2000 CHECK (startdate > DATE '2000-01-01');
ALTER TABLE Political_campaign.campaign
  DROP CONSTRAINT IF EXISTS chk_campaign_donations_nonneg;
ALTER TABLE Political_campaign.campaign
  ADD CONSTRAINT chk_campaign_donations_nonneg CHECK (donationsgoal >= 0);
----
CREATE TABLE IF NOT EXISTS Political_campaign.donortype (
    donortypeid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    typename    VARCHAR(50) NOT NULL UNIQUE
);
ALTER TABLE Political_campaign.donortype
  DROP CONSTRAINT IF EXISTS chk_donortype_values;
ALTER TABLE Political_campaign.donortype
  ADD CONSTRAINT chk_donortype_values CHECK (typename IN ('Individual','Corporate','PAC'));

----
CREATE TABLE IF NOT EXISTS Political_campaign.volunteerrole (
    roleid         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rolename       VARCHAR(50) NOT NULL,
    roledescription VARCHAR(255),
    CONSTRAINT uq_volunteerrole_name UNIQUE (rolename)
);
----
CREATE TABLE IF NOT EXISTS Political_campaign.task (
    taskid          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    roleid          BIGINT NOT NULL,
    taskdescription VARCHAR(255) NOT NULL,
    CONSTRAINT fk_task_role FOREIGN KEY (roleid) REFERENCES Political_campaign.
  volunteerrole(roleid)
);
----
CREATE TABLE IF NOT EXISTS Political_campaign.donor (
    donorid     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    donortypeid BIGINT NOT NULL,
    name        VARCHAR(127) NOT NULL,
    email       VARCHAR(50),
    phone       VARCHAR(50),
    CONSTRAINT fk_donor_donortype FOREIGN KEY (donortypeid) REFERENCES Political_campaign.
  donortype(donortypeid)
);
----
CREATE TABLE IF NOT EXISTS Political_campaign.problem (
    problemid   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaignid  BIGINT NOT NULL,
    description VARCHAR(255),
    CONSTRAINT fk_problem_campaign FOREIGN KEY (campaignid) REFERENCES Political_campaign.
  campaign(campaignid)
);
----
CREATE TABLE IF NOT EXISTS Political_campaign.oppositionresearch (
    researchid  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaignid  BIGINT NOT NULL,
    opponent    VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    CONSTRAINT fk_opresearch_campaign FOREIGN KEY (campaignid) REFERENCES Political_campaign.
  campaign(campaignid)
);
----
CREATE TABLE IF NOT EXISTS Political_campaign.event (
    eventid     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaignid  BIGINT NOT NULL,
    eventtype   VARCHAR(50) NOT NULL,
    eventdate   DATE NOT NULL DEFAULT CURRENT_DATE,
    location    VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    CONSTRAINT fk_event_campaign FOREIGN KEY (campaignid) REFERENCES Political_campaign.
  campaign(campaignid)
);
ALTER TABLE Political_campaign.event
  DROP CONSTRAINT IF EXISTS chk_event_date_after_2000;
ALTER TABLE Political_campaign.event
  ADD CONSTRAINT chk_event_date_after_2000 CHECK (eventdate > DATE '2000-01-01');
ALTER TABLE Political_campaign.event
  DROP CONSTRAINT IF EXISTS chk_event_type_values;
ALTER TABLE Political_campaign.event
  ADD CONSTRAINT chk_event_type_values CHECK (eventtype IN ('Rally','Fundraiser','Canvass','Meeting'));

----
CREATE TABLE IF NOT EXISTS Political_campaign.volunteer (
    volunteerid  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    firstname    VARCHAR(50) NOT NULL,
    lastname     VARCHAR(50) NOT NULL,
    dateofbirth  DATE,
    address      VARCHAR(255),
    email        VARCHAR(50),
    phone        VARCHAR(50),
    campaignid   BIGINT,
    availability VARCHAR(255),
    CONSTRAINT fk_volunteer_campaign FOREIGN KEY (campaignid) REFERENCES Political_campaign.
  campaign(campaignid)
);

----
CREATE TABLE IF NOT EXISTS Political_campaign.voter (
    voterid     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    firstname   VARCHAR(50) NOT NULL,
    lastname    VARCHAR(50) NOT NULL,
    dateofbirth DATE,
    address     VARCHAR(255),
    email       VARCHAR(50),
    phone       VARCHAR(50)
);

----
CREATE TABLE IF NOT EXISTS Political_campaign.survey (
    surveyid    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaignid  BIGINT NOT NULL,
    surveyname  VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    CONSTRAINT fk_survey_campaign FOREIGN KEY (campaignid) REFERENCES Political_campaign.
  campaign(campaignid)
);

----
CREATE TABLE IF NOT EXISTS Political_campaign.vote (
    voteid       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    surveyid     BIGINT NOT NULL,
    voterid      BIGINT NOT NULL,
    responsetext VARCHAR(255),
    datevoted    DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_vote_survey FOREIGN KEY (surveyid) REFERENCES Political_campaign.
  survey(surveyid),
    CONSTRAINT fk_vote_voter FOREIGN KEY (voterid) REFERENCES Political_campaign.
  voter(voterid)
);
ALTER TABLE Political_campaign.vote
  DROP CONSTRAINT IF EXISTS chk_vote_date_after_2000;
ALTER TABLE Political_campaign.vote
  ADD CONSTRAINT chk_vote_date_after_2000 CHECK (datevoted > DATE '2000-01-01');

----
CREATE TABLE IF NOT EXISTS Political_campaign.donation (
    donationid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    donorid    BIGINT NOT NULL,
    eventid    BIGINT,
    date       DATE NOT NULL DEFAULT CURRENT_DATE,
    amount     NUMERIC(12,2) NOT NULL,
    CONSTRAINT fk_donation_donor FOREIGN KEY (donorid) REFERENCES Political_campaign.
  donor(donorid),
    CONSTRAINT fk_donation_event FOREIGN KEY (eventid) REFERENCES Political_campaign.
  event(eventid)
);
ALTER TABLE Political_campaign.donation
  DROP CONSTRAINT IF EXISTS chk_donation_amount_nonneg;
ALTER TABLE Political_campaign.donation
  ADD CONSTRAINT chk_donation_amount_nonneg CHECK (amount >= 0);
ALTER TABLE Political_campaign.donation
  DROP CONSTRAINT IF EXISTS chk_donation_date_after_2000;
ALTER TABLE Political_campaign.donation
  ADD CONSTRAINT chk_donation_date_after_2000 CHECK (date > DATE '2000-01-01');

----
CREATE TABLE IF NOT EXISTS Political_campaign.eventvolunteer (
    eventid     BIGINT NOT NULL,
    volunteerid BIGINT NOT NULL,
    taskid      BIGINT,
    PRIMARY KEY (eventid, volunteerid),
    CONSTRAINT fk_ev_event FOREIGN KEY (eventid) REFERENCES Political_campaign.
  event(eventid),
    CONSTRAINT fk_ev_volunteer FOREIGN KEY (volunteerid) REFERENCES Political_campaign.
  volunteer(volunteerid),
    CONSTRAINT fk_ev_task FOREIGN KEY (taskid) REFERENCES Political_campaign.
  task(taskid)
);
---------------------------------------------------------------------
--POPULATING TABLES WITHOUT HARDCODING
INSERT INTO Political_campaign.donortype (typename) SELECT 'Individual' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donortype WHERE typename = 'Individual');
INSERT INTO Political_campaign.donortype (typename) SELECT 'Corporate' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donortype WHERE typename = 'Corporate');
INSERT INTO Political_campaign.donortype (typename) SELECT 'PAC' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donortype WHERE typename = 'PAC');
INSERT INTO Political_campaign.volunteerrole (rolename, roledescription) SELECT 'Canvasser', 'Responsible for canvasser activities.' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteerrole WHERE rolename = 'Canvasser');
INSERT INTO Political_campaign.volunteerrole (rolename, roledescription) SELECT 'Phone Banker', 'Responsible for phone banker activities.' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteerrole WHERE rolename = 'Phone Banker');
INSERT INTO Political_campaign.volunteerrole (rolename, roledescription) SELECT 'Event Coordinator', 'Responsible for event coordinator activities.' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteerrole WHERE rolename = 'Event Coordinator');
INSERT INTO Political_campaign.volunteerrole (rolename, roledescription) SELECT 'Data Entry Clerk', 'Responsible for data entry clerk activities.' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteerrole WHERE rolename = 'Data Entry Clerk');
INSERT INTO Political_campaign.volunteerrole (rolename, roledescription) SELECT 'Fundraiser', 'Responsible for fundraiser activities.' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteerrole WHERE rolename = 'Fundraiser');
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Canvasser'), 'Primary task for Canvasser' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Primary task for Canvasser' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Canvasser'));
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Canvasser'), 'Secondary task for Canvasser' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Secondary task for Canvasser' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Canvasser'));
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Phone Banker'), 'Primary task for Phone Banker' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Primary task for Phone Banker' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Phone Banker'));
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Phone Banker'), 'Secondary task for Phone Banker' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Secondary task for Phone Banker' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Phone Banker'));
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Event Coordinator'), 'Primary task for Event Coordinator' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Primary task for Event Coordinator' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Event Coordinator'));
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Event Coordinator'), 'Secondary task for Event Coordinator' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Secondary task for Event Coordinator' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Event Coordinator'));
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Data Entry Clerk'), 'Primary task for Data Entry Clerk' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Primary task for Data Entry Clerk' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Data Entry Clerk'));
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Data Entry Clerk'), 'Secondary task for Data Entry Clerk' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Secondary task for Data Entry Clerk' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Data Entry Clerk'));
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Fundraiser'), 'Primary task for Fundraiser' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Primary task for Fundraiser' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Fundraiser'));
INSERT INTO Political_campaign.task (roleid, taskdescription) SELECT (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Fundraiser'), 'Secondary task for Fundraiser' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.task WHERE taskdescription = 'Secondary task for Fundraiser' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Fundraiser'));
INSERT INTO Political_campaign.campaign (candidate, startdate, enddate, donationsgoal, description) SELECT 'Noah Garcia', '2021-11-01', NULL, 8098265, 'Campaign for Noah Garcia' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia' AND startdate = '2021-11-01');
INSERT INTO Political_campaign.campaign (candidate, startdate, enddate, donationsgoal, description) SELECT 'Grace Lewis', '2024-10-13', NULL, 8425293, 'Campaign for Grace Lewis' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis' AND startdate = '2024-10-13');
INSERT INTO Political_campaign.campaign (candidate, startdate, enddate, donationsgoal, description) SELECT 'Quinn Harris', '2023-01-28', '2025-02-19', 8701241, 'Campaign for Quinn Harris' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris' AND startdate = '2023-01-28');
INSERT INTO Political_campaign.donor (donortypeid, name, email, phone) SELECT (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate'), 'Bob Davis Corp', NULL, '555-590-8122' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donor WHERE name = 'Bob Davis Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate'));
INSERT INTO Political_campaign.donor (donortypeid, name, email, phone) SELECT (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate'), 'Sam Johnson Corp', 'sam.johnson.corp@example.com', NULL WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donor WHERE name = 'Sam Johnson Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate'));
INSERT INTO Political_campaign.donor (donortypeid, name, email, phone) SELECT (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate'), 'Alice Clark Corp', NULL, '555-511-8344' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donor WHERE name = 'Alice Clark Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate'));
INSERT INTO Political_campaign.donor (donortypeid, name, email, phone) SELECT (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate'), 'Mia Garcia Corp', NULL, '555-689-5210' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donor WHERE name = 'Mia Garcia Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate'));
INSERT INTO Political_campaign.donor (donortypeid, name, email, phone) SELECT (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Individual'), 'Karen Jackson', 'karen.jackson@example.com', NULL WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donor WHERE name = 'Karen Jackson' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Individual'));
INSERT INTO Political_campaign.problem (campaignid, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'), 'Problem 1 description' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.problem WHERE description = 'Problem 1 description' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'));
INSERT INTO Political_campaign.problem (campaignid, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'), 'Problem 2 description' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.problem WHERE description = 'Problem 2 description' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'));
INSERT INTO Political_campaign.problem (campaignid, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'), 'Problem 3 description' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.problem WHERE description = 'Problem 3 description' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'));
INSERT INTO Political_campaign.problem (campaignid, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'), 'Problem 4 description' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.problem WHERE description = 'Problem 4 description' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'));
INSERT INTO Political_campaign.oppositionresearch (campaignid, opponent, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'), 'Eve Rodriguez', 'Research on Eve Rodriguez' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.oppositionresearch WHERE opponent = 'Eve Rodriguez' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'));
INSERT INTO Political_campaign.oppositionresearch (campaignid, opponent, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'), 'Jack Jackson', 'Research on Jack Jackson' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.oppositionresearch WHERE opponent = 'Jack Jackson' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'));
INSERT INTO Political_campaign.oppositionresearch (campaignid, opponent, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'), 'Mia Martinez', 'Research on Mia Martinez' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.oppositionresearch WHERE opponent = 'Mia Martinez' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'));
INSERT INTO Political_campaign.event (campaignid, eventtype, eventdate, location, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'), 'Meeting', '2021-02-13', 'Los Angeles', 'Meeting event in Los Angeles' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.event WHERE eventtype = 'Meeting' AND eventdate = '2021-02-13' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'));
INSERT INTO Political_campaign.event (campaignid, eventtype, eventdate, location, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'), 'Canvass', '2023-12-14', 'Los Angeles', 'Canvass event in Los Angeles' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2023-12-14' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'));
INSERT INTO Political_campaign.event (campaignid, eventtype, eventdate, location, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'), 'Canvass', '2022-03-18', 'New York', 'Canvass event in New York' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2022-03-18' AND location = 'New York' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'));
INSERT INTO Political_campaign.event (campaignid, eventtype, eventdate, location, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'), 'Fundraiser', '2022-01-25', 'Phoenix', 'Fundraiser event in Phoenix' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.event WHERE eventtype = 'Fundraiser' AND eventdate = '2022-01-25' AND location = 'Phoenix' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'));
INSERT INTO Political_campaign.volunteer (firstname, lastname, dateofbirth, address, email, phone, campaignid, availability) SELECT 'Henry', 'Taylor', '1961-01-26', '624 Main St, Somewhere', 'henry.taylor@example.com', '555-374-5741', NULL, 'Weekends' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteer WHERE firstname = 'Henry' AND lastname = 'Taylor' AND dateofbirth = '1961-01-26' AND campaignid IS NULL);
INSERT INTO Political_campaign.volunteer (firstname, lastname, dateofbirth, address, email, phone, campaignid, availability) SELECT 'Ivy', 'Thomas', '1966-09-30', '199 Main St, Anytown', 'ivy.thomas@example.com', '555-227-1235', (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'), 'Evenings' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteer WHERE firstname = 'Ivy' AND lastname = 'Thomas' AND dateofbirth = '1966-09-30' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'));
INSERT INTO Political_campaign.volunteer (firstname, lastname, dateofbirth, address, email, phone, campaignid, availability) SELECT 'Sam', 'Smith', '1972-07-10', '535 Main St, Somewhere', 'sam.smith@example.com', '555-544-6761', NULL, 'Weekends' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteer WHERE firstname = 'Sam' AND lastname = 'Smith' AND dateofbirth = '1972-07-10' AND campaignid IS NULL);
INSERT INTO Political_campaign.volunteer (firstname, lastname, dateofbirth, address, email, phone, campaignid, availability) SELECT 'Bob', 'Jackson', '1969-06-24', '561 Main St, Anytown', NULL, NULL, (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'), 'Evenings' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteer WHERE firstname = 'Bob' AND lastname = 'Jackson' AND dateofbirth = '1969-06-24' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Noah Garcia'));
INSERT INTO Political_campaign.volunteer (firstname, lastname, dateofbirth, address, email, phone, campaignid, availability) SELECT 'Noah', 'Taylor', '1978-10-31', '823 Main St, Anytown', 'noah.taylor@example.com', '555-773-3435', (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'), 'Full time' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.volunteer WHERE firstname = 'Noah' AND lastname = 'Taylor' AND dateofbirth = '1978-10-31' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'));
INSERT INTO Political_campaign.voter (firstname, lastname, dateofbirth, address, email, phone) SELECT 'Grace', 'Taylor', '1976-09-18', '845 Main St, Somewhere', 'grace.taylor@example.com', NULL WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.voter WHERE firstname = 'Grace' AND lastname = 'Taylor' AND dateofbirth = '1976-09-18');
INSERT INTO Political_campaign.voter (firstname, lastname, dateofbirth, address, email, phone) SELECT 'Eve', 'Davis', '1957-09-19', '348 Main St, Anytown', 'eve.davis@example.com', '555-401-8333' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Davis' AND dateofbirth = '1957-09-19');
INSERT INTO Political_campaign.voter (firstname, lastname, dateofbirth, address, email, phone) SELECT 'Mia', 'Lewis', '1976-10-29', '151 Main St, Somewhere', NULL, '555-379-1770' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.voter WHERE firstname = 'Mia' AND lastname = 'Lewis' AND dateofbirth = '1976-10-29');
INSERT INTO Political_campaign.voter (firstname, lastname, dateofbirth, address, email, phone) SELECT 'Eve', 'Robinson', '1957-09-28', '763 Main St, Cityville', 'eve.robinson@example.com', '555-737-1350' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Robinson' AND dateofbirth = '1957-09-28');
INSERT INTO Political_campaign.survey (campaignid, surveyname, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'), 'Survey 1 - Charlie Robinson', 'Description for Survey 1 - Charlie Robinson' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.survey WHERE surveyname = 'Survey 1 - Charlie Robinson' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'));
INSERT INTO Political_campaign.survey (campaignid, surveyname, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'), 'Survey 2 - Leo Martinez', 'Description for Survey 2 - Leo Martinez' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.survey WHERE surveyname = 'Survey 2 - Leo Martinez' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris'));
INSERT INTO Political_campaign.survey (campaignid, surveyname, description) SELECT (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'), 'Survey 3 - Mia Lewis', 'Description for Survey 3 - Mia Lewis' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.survey WHERE surveyname = 'Survey 3 - Mia Lewis' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis'));
INSERT INTO Political_campaign.vote (surveyid, voterid, responsetext, datevoted) SELECT (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 1 - Charlie Robinson' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Robinson' AND dateofbirth = '1957-09-28'), 'Undecided', '2024-03-30' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.vote WHERE surveyid = (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 1 - Charlie Robinson' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')) AND voterid = (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Robinson' AND dateofbirth = '1957-09-28') AND datevoted = '2024-03-30');
INSERT INTO Political_campaign.vote (surveyid, voterid, responsetext, datevoted) SELECT (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 3 - Mia Lewis' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')), (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Robinson' AND dateofbirth = '1957-09-28'), 'Undecided', '2025-04-01' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.vote WHERE surveyid = (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 3 - Mia Lewis' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')) AND voterid = (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Robinson' AND dateofbirth = '1957-09-28') AND datevoted = '2025-04-01');
INSERT INTO Political_campaign.vote (surveyid, voterid, responsetext, datevoted) SELECT (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 1 - Charlie Robinson' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Davis' AND dateofbirth = '1957-09-19'), 'Undecided', '2023-11-27' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.vote WHERE surveyid = (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 1 - Charlie Robinson' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')) AND voterid = (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Davis' AND dateofbirth = '1957-09-19') AND datevoted = '2023-11-27');
INSERT INTO Political_campaign.vote (surveyid, voterid, responsetext, datevoted) SELECT (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 2 - Leo Martinez' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Davis' AND dateofbirth = '1957-09-19'), 'Oppose', '2024-05-28' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.vote WHERE surveyid = (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 2 - Leo Martinez' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')) AND voterid = (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Davis' AND dateofbirth = '1957-09-19') AND datevoted = '2024-05-28');
INSERT INTO Political_campaign.vote (surveyid, voterid, responsetext, datevoted) SELECT (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 2 - Leo Martinez' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Robinson' AND dateofbirth = '1957-09-28'), 'Undecided', '2020-08-12' WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.vote WHERE surveyid = (SELECT surveyid FROM Political_campaign.survey WHERE surveyname = 'Survey 2 - Leo Martinez' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')) AND voterid = (SELECT voterid FROM Political_campaign.voter WHERE firstname = 'Eve' AND lastname = 'Robinson' AND dateofbirth = '1957-09-28') AND datevoted = '2020-08-12');
INSERT INTO Political_campaign.donation (donorid, eventid, date, amount) SELECT (SELECT donorid FROM Political_campaign.donor WHERE name = 'Mia Garcia Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate')), (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Meeting' AND eventdate = '2021-02-13' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), '2021-04-19', 1206.81 WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donation WHERE donorid = (SELECT donorid FROM Political_campaign.donor WHERE name = 'Mia Garcia Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate')) AND date = '2021-04-19' AND eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Meeting' AND eventdate = '2021-02-13' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')));
INSERT INTO Political_campaign.donation (donorid, eventid, date, amount) SELECT (SELECT donorid FROM Political_campaign.donor WHERE name = 'Bob Davis Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate')), (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Fundraiser' AND eventdate = '2022-01-25' AND location = 'Phoenix' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), '2020-10-20', 8824.16 WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donation WHERE donorid = (SELECT donorid FROM Political_campaign.donor WHERE name = 'Bob Davis Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate')) AND date = '2020-10-20' AND eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Fundraiser' AND eventdate = '2022-01-25' AND location = 'Phoenix' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')));
INSERT INTO Political_campaign.donation (donorid, eventid, date, amount) SELECT (SELECT donorid FROM Political_campaign.donor WHERE name = 'Mia Garcia Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate')), (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Meeting' AND eventdate = '2021-02-13' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), '2025-04-24', 3274.39 WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donation WHERE donorid = (SELECT donorid FROM Political_campaign.donor WHERE name = 'Mia Garcia Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate')) AND date = '2025-04-24' AND eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Meeting' AND eventdate = '2021-02-13' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')));
INSERT INTO Political_campaign.donation (donorid, eventid, date, amount) SELECT (SELECT donorid FROM Political_campaign.donor WHERE name = 'Bob Davis Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate')), (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2022-03-18' AND location = 'New York' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')), '2024-09-11', 6233.17 WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donation WHERE donorid = (SELECT donorid FROM Political_campaign.donor WHERE name = 'Bob Davis Corp' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Corporate')) AND date = '2024-09-11' AND eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2022-03-18' AND location = 'New York' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')));
INSERT INTO Political_campaign.donation (donorid, eventid, date, amount) SELECT (SELECT donorid FROM Political_campaign.donor WHERE name = 'Karen Jackson' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Individual')), (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Fundraiser' AND eventdate = '2022-01-25' AND location = 'Phoenix' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), '2024-04-19', 3322.42 WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.donation WHERE donorid = (SELECT donorid FROM Political_campaign.donor WHERE name = 'Karen Jackson' AND donortypeid = (SELECT donortypeid FROM Political_campaign.donortype WHERE typename = 'Individual')) AND date = '2024-04-19' AND eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Fundraiser' AND eventdate = '2022-01-25' AND location = 'Phoenix' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')));
INSERT INTO Political_campaign.eventvolunteer (eventid, volunteerid, taskid) SELECT (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2022-03-18' AND location = 'New York' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')), (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Sam' AND lastname = 'Smith' AND dateofbirth = '1972-07-10'), (SELECT taskid FROM Political_campaign.task WHERE taskdescription = 'Primary task for Data Entry Clerk' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Data Entry Clerk')) WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.eventvolunteer WHERE eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2022-03-18' AND location = 'New York' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')) AND volunteerid = (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Sam' AND lastname = 'Smith' AND dateofbirth = '1972-07-10'));
INSERT INTO Political_campaign.eventvolunteer (eventid, volunteerid, taskid) SELECT (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2023-12-14' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Sam' AND lastname = 'Smith' AND dateofbirth = '1972-07-10'), NULL WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.eventvolunteer WHERE eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2023-12-14' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')) AND volunteerid = (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Sam' AND lastname = 'Smith' AND dateofbirth = '1972-07-10'));
INSERT INTO Political_campaign.eventvolunteer (eventid, volunteerid, taskid) SELECT (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2023-12-14' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')), (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Henry' AND lastname = 'Taylor' AND dateofbirth = '1961-01-26'), NULL WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.eventvolunteer WHERE eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2023-12-14' AND location = 'Los Angeles' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Quinn Harris')) AND volunteerid = (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Henry' AND lastname = 'Taylor' AND dateofbirth = '1961-01-26'));
INSERT INTO Political_campaign.eventvolunteer (eventid, volunteerid, taskid) SELECT (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2022-03-18' AND location = 'New York' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')), (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Noah' AND lastname = 'Taylor' AND dateofbirth = '1978-10-31'), NULL WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.eventvolunteer WHERE eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2022-03-18' AND location = 'New York' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')) AND volunteerid = (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Noah' AND lastname = 'Taylor' AND dateofbirth = '1978-10-31'));
INSERT INTO Political_campaign.eventvolunteer (eventid, volunteerid, taskid) SELECT (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2022-03-18' AND location = 'New York' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')), (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Ivy' AND lastname = 'Thomas' AND dateofbirth = '1966-09-30'), (SELECT taskid FROM Political_campaign.task WHERE taskdescription = 'Secondary task for Canvasser' AND roleid = (SELECT roleid FROM Political_campaign.volunteerrole WHERE rolename = 'Canvasser')) WHERE NOT EXISTS (SELECT 1 FROM Political_campaign.eventvolunteer WHERE eventid = (SELECT eventid FROM Political_campaign.event WHERE eventtype = 'Canvass' AND eventdate = '2022-03-18' AND location = 'New York' AND campaignid = (SELECT campaignid FROM Political_campaign.campaign WHERE candidate = 'Grace Lewis')) AND volunteerid = (SELECT volunteerid FROM Political_campaign.volunteer WHERE firstname = 'Ivy' AND lastname = 'Thomas' AND dateofbirth = '1966-09-30'));

---------------------------------------------
ALTER TABLE Political_campaign.campaign ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.donortype ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.volunteerrole ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.task ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.donor ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.problem ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.oppositionresearch ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.event ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.volunteer ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.voter ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.survey ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.vote ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.donation ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Political_campaign.eventvolunteer ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
