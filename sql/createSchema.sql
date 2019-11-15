CREATE TABLE Medical_Facility (
		f_id INT,
		name VARCHAR2(30),
		capacity INT,
		classification VARCHAR2(10) CHECK( classification IN ('01','02','03')),
		no_sdepts INT,
		numb INT,
		street VARCHAR2(50),
		city  VARCHAR2(30),
		state  VARCHAR2(30),
		country VARCHAR2(30),
		PRIMARY KEY (f_id)
);

CREATE TABLE Certifications (
		acronym VARCHAR2(3),
		name VARCHAR2(50),
		c_date DATE,
		e_date DATE,
		PRIMARY KEY (acronym)
);

CREATE TABLE Facility_Certified (
		f_id INT,
		acronym VARCHAR2(3),
		certifed_date DATE DEFAULT NULL,
		expiration_date DATE DEFAULT NULL,
		PRIMARY KEY (f_id, acronym),
		FOREIGN KEY (f_id) REFERENCES Medical_Facility ON DELETE CASCADE,
		FOREIGN KEY (acronym) REFERENCES Certifications ON DELETE CASCADE
);

CREATE TABLE Staff (
		e_id VARCHAR2(20),
		fname VARCHAR2(30),
		lname VARCHAR2(30),
		designation VARCHAR2(2) CHECK( designation IN ('M','NM')),
		dob DATE,
		hire_date DATE,
		addr VARCHAR2(100) DEFAULT NULL,
		city VARCHAR2(30),
		primary_dept VARCHAR2(20) NOT NULL,
		PRIMARY KEY (e_id)
);

CREATE TABLE Medical_Staff (
		e_id VARCHAR2(20),
		PRIMARY KEY (e_id),
		FOREIGN KEY (e_id) REFERENCES Staff ON DELETE CASCADE
);

CREATE TABLE Non_Medical_Staff (
		e_id VARCHAR2(20),
		PRIMARY KEY (e_id),
		FOREIGN KEY (e_id) REFERENCES Staff ON DELETE CASCADE
);

CREATE TABLE Service_department (
		code VARCHAR2(20),
		name VARCHAR2(30),
		director_id VARCHAR2(20) NOT NULL,
		PRIMARY KEY (code),
		FOREIGN KEY (director_id) REFERENCES Staff(e_id) ON DELETE SET NULL
);

CREATE TABLE Facility_has_Dept (
		f_id INT,
		code VARCHAR2(20),
		PRIMARY KEY (f_id, code),
		FOREIGN KEY (f_id) REFERENCES Medical_Facility ON DELETE CASCADE,
		FOREIGN KEY (code) REFERENCES Service_department ON DELETE CASCADE
);

CREATE TABLE Secondary_Works_Dept (
		e_id VARCHAR2(20),
		code VARCHAR2(20),
		PRIMARY KEY (e_id, code),
		FOREIGN KEY (e_id) REFERENCES Staff ON DELETE CASCADE,
		FOREIGN KEY (code) REFERENCES Service_department ON DELETE CASCADE
);

CREATE TABLE Body_Parts (
		code VARCHAR2(20),
		name VARCHAR2(30),
		PRIMARY KEY (code)
);

CREATE TABLE Specialized_For (
		b_code VARCHAR2(20),
		s_code VARCHAR2(20),
		PRIMARY KEY (b_code, s_code),
		FOREIGN KEY (s_code) REFERENCES Service_department(code) ON DELETE CASCADE,
		FOREIGN KEY (b_code) REFERENCES Body_Parts(code) ON DELETE CASCADE
);

CREATE TABLE Services (
		code VARCHAR2(20),
		name VARCHAR2(30),
		PRIMARY KEY (code)
);

CREATE TABLE Dept_Provides_Service (
		sdcode VARCHAR2(20),
		secode VARCHAR2(20),
		PRIMARY KEY (sdcode,secode),
		FOREIGN KEY (sdcode) REFERENCES Service_department(code) ON DELETE CASCADE,
		FOREIGN KEY (secode) REFERENCES Services(code) ON DELETE CASCADE
);

CREATE TABLE Equipments (
		name VARCHAR2(30),
		PRIMARY KEY (name)
);

CREATE TABLE Performed_using (
		code VARCHAR2(20),
		name VARCHAR2(30),
		PRIMARY KEY (code, name),
		FOREIGN KEY (code) REFERENCES Services(code) ON DELETE CASCADE,
		FOREIGN KEY (name) REFERENCES Equipments(name) ON DELETE CASCADE
);

CREATE TABLE Patient (
		p_id INT,
		fname VARCHAR2(30),
		lname VARCHAR2(30),
		dob DATE,
		phone_no VARCHAR2(10),
		numb INT,
		street VARCHAR2(50),
		city  VARCHAR2(30),
		state  VARCHAR2(30),
		country VARCHAR2(30),
		CONSTRAINT unique_login_id UNIQUE (lname, dob, city),
		PRIMARY KEY (p_id)
);

CREATE TABLE Checks_In (
		v_id INT,
		p_id INT,
		f_id INT,
		temp INT,
		bp_systolic INT,
		bp_diastolic INT,
		checkin_start_time TIMESTAMP,
		checkin_end_time TIMESTAMP,
		trtment_start_time TIMESTAMP,
		discharge_time TIMESTAMP,
		priority VARCHAR2(10) CHECK( priority IN ('High', 'Medium', 'Low')),
		dis_status VARCHAR2(25) CHECK( dis_status IN ('Treated Successfully', 'Deceased', 'Referred')),
		treatment VARCHAR2(30) DEFAULT 'false' CHECK( treatment IN ('false', 'true')) ,
		trmt_description VARCHAR2(100) DEFAULT NULL,
		neg_exp VARCHAR2(30),
		neg_code INT DEFAULT 0 CHECK( neg_code IN (0, 1, 2)),
		acknowledged VARCHAR2(30) CHECK( acknowledged IN ('yes', 'no')),
		PRIMARY KEY (v_id),
		FOREIGN KEY (f_id) REFERENCES Medical_Facility(f_id) ON DELETE SET NULL,
		FOREIGN KEY (p_id) REFERENCES Patient(p_id) ON DELETE SET NULL
);

CREATE TABLE Severity (
		s_id INT,
		type VARCHAR2(30),
		PRIMARY KEY (s_id)
);

CREATE TABLE Symptoms (
		code VARCHAR2(10),
		b_code VARCHAR2(20),
		name VARCHAR2(30),
		severity_type INT,
		PRIMARY KEY (code),
		FOREIGN KEY (b_code) REFERENCES Body_Parts(code) ON DELETE SET NULL,
		FOREIGN KEY (severity_type) REFERENCES Severity(s_id) ON DELETE SET NULL
);

CREATE TABLE Affected_Info (
		v_id INT,
		s_code VARCHAR2(10),
		b_code VARCHAR2(20) DEFAULT 'OTH000',
		duration NUMBER,
		is_first VARCHAR2(5) CHECK( is_first IN ('true', 'false', NULL)),
		incident VARCHAR2(30),
		optional_description VARCHAR2(100) DEFAULT NULL,
		sev_value VARCHAR2(30),
		PRIMARY KEY (v_id, s_code, b_code),
		FOREIGN KEY (v_id) REFERENCES Checks_In(v_id) ON DELETE CASCADE,
		FOREIGN KEY (b_code) REFERENCES Body_Parts(code) ON DELETE SET NULL,
		FOREIGN KEY (s_code) REFERENCES Symptoms(code) ON DELETE CASCADE
);

CREATE TABLE Reasons (
		r_id INT,
		description VARCHAR2(100),
		PRIMARY KEY (r_id)
);

CREATE TABLE Referred_to(	
		f_id INT,
		v_id INT,
		e_id VARCHAR2(20),
		PRIMARY KEY (v_id),
		FOREIGN KEY (f_id) REFERENCES Medical_Facility(f_id) ON DELETE SET NULL,
		FOREIGN KEY (v_id) REFERENCES Checks_In(v_id) ON DELETE CASCADE,
		FOREIGN KEY (e_id) REFERENCES Medical_Staff(e_id) ON DELETE SET NULL
);

CREATE TABLE Referral_Reason (
		v_id INT,
		r_id INT,
		s_code VARCHAR2(20),
		description VARCHAR2(200),
		PRIMARY KEY (v_id, r_id, s_code, description),
		FOREIGN KEY (s_code) REFERENCES Services(code) ON DELETE SET NULL,
		FOREIGN KEY (v_id) REFERENCES Checks_In(v_id) ON DELETE CASCADE,
		FOREIGN KEY (r_id) REFERENCES Reasons(r_id) ON DELETE CASCADE
);

CREATE TABLE Rule_Priority ( 
		asn_id INT,
		priority VARCHAR2(50) CHECK( priority IN ('HIGH', 'NORMAL', 'QUARANTINE')),
		PRIMARY KEY (asn_id)
);

CREATE TABLE Assessment_Rules ( 
		ar_id INT,
		s_code VARCHAR2(10),
		b_code VARCHAR2(20),
		comparison CHAR(2) CHECK( comparison IN ('>', '=', '<', '>=', '<=', '!=')),
		severity_val VARCHAR2(30),
		PRIMARY KEY (ar_id, s_code, b_code, severity_val),
		FOREIGN KEY (s_code) REFERENCES symptoms(code) ON DELETE CASCADE,
		FOREIGN KEY (b_code) REFERENCES body_parts(code) ON DELETE CASCADE,
		FOREIGN KEY (ar_id) REFERENCES Rule_Priority(asn_id) ON DELETE CASCADE
);


