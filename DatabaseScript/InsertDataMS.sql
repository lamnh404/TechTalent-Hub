USE [TechTalentHub];
GO


INSERT INTO [User] ([Email], [PasswordHash], [UserType], [AccountStatus], [RegistrationDate]) VALUES
(N'admin@techtalenthub.com', N'$2a$12$yF6QALwl2DVbZ7X1iQiF/ONXNUhBcm2Hj8abEMJvuQqJaFLvF7zxi', N'Admin', N'Active', N'2024-01-15 09:00:00'),
(N'hr@fpt.com.vn', N'$2a$12$3IqAi1nQr6rsSzAO8Tr2YutQIJwDSpKFHl060VGI8FxuO58TLaZAK', N'Company', N'Active', N'2024-02-01 10:30:00'),
(N'recruitment@vng.com.vn', N'$2a$12$3IqAi1nQr6rsSzAO8Tr2YutQIJwDSpKFHl060VGI8FxuO58TLaZAK', N'Company', N'Active', N'2024-02-05 14:20:00'),
(N'talent@techcombank.com.vn', N'$2a$12$3IqAi1nQr6rsSzAO8Tr2YutQIJwDSpKFHl060VGI8FxuO58TLaZAK', N'Company', N'Active', N'2024-02-10 11:15:00'),
(N'hr@viettel.com.vn', N'$2a$12$3IqAi1nQr6rsSzAO8Tr2YutQIJwDSpKFHl060VGI8FxuO58TLaZAK', N'Company', N'Active', N'2024-02-15 16:45:00'),
(N'nguyen.van.a@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-01 08:00:00'),
(N'tran.thi.b@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-05 09:30:00'),
(N'le.van.c@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-10 10:45:00'),
(N'pham.thi.d@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-15 13:20:00'),
(N'hoang.van.e@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-20 15:00:00');
GO


DECLARE @AdminId NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'admin@techtalenthub.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');
DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');

INSERT INTO [Admin] ([AdminId], [AdminName], [AdminRole], [DateAssigned])
SELECT @AdminId, N'System Administrator', N'SuperAdmin', N'2024-01-15 09:00:00';
GO


DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [Company] ([CompanyID], [CompanyName], [FounderYear], [CompanySize], [Industry], [CompanyDescription], [CompanyWebsite], [VerificationStatus], [LogoURL])
SELECT @CompanyId1, N'FPT Software', 1999, N'Enterprise', N'Information Technology', 
 N'Leading software outsourcing company in Vietnam with over 30,000 employees worldwide. Specializing in digital transformation, AI, cloud computing, and enterprise solutions.',
 N'https://fptsoftware.com', N'ACCEPTED', N'https://fptsoftware.com/logo.png'
UNION ALL
SELECT @CompanyId2, N'VNG Corporation', 2004, N'Large', N'Technology & Entertainment',
 N'Pioneer in online games, digital content, and e-commerce platforms in Vietnam. Creator of Zalo, Vietnam''s leading messaging app with over 70 million users.',
 N'https://vng.com.vn', N'ACCEPTED', N'https://vng.com.vn/logo.png'
UNION ALL
SELECT @CompanyId3, N'Vietnam Technological and Commercial Joint Stock Bank', 1993, N'Large', N'Banking & Finance',
 N'One of the leading commercial banks in Vietnam with cutting-edge fintech solutions. Recognized for innovation in digital banking and customer experience.',
 N'https://techcombank.com.vn', N'ACCEPTED', N'https://techcombank.com.vn/logo.png'
UNION ALL
SELECT @CompanyId4, N'Viettel Group', 1989, N'Enterprise', N'Telecommunications',
 N'Largest telecommunications company in Vietnam providing mobile, internet, and digital services. Expanding into AI, IoT, cloud computing, and cybersecurity solutions.',
 N'https://viettel.com.vn', N'ACCEPTED', N'https://viettel.com.vn/logo.png';
GO


DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [CompanyLocation] ([CompanyID], [Address])
SELECT @CompanyId1, N'FPT Building, Tan Thuan EPZ, District 7, HCMC'
UNION ALL SELECT @CompanyId1, N'FPT Tower, Duy Tan Street, Cau Giay, Hanoi'
UNION ALL SELECT @CompanyId2, N'VNG Campus, Z06 Street, Tan Thuan EPZ, District 7, HCMC'
UNION ALL SELECT @CompanyId2, N'VNG Hanoi Office, Keangnam Landmark 72, Pham Hung, Hanoi'
UNION ALL SELECT @CompanyId3, N'Techcombank Tower, 191 Ba Trieu, Hai Ba Trung, Hanoi'
UNION ALL SELECT @CompanyId3, N'162-164 Pasteur, Ben Nghe Ward, District 1, HCMC'
UNION ALL SELECT @CompanyId4, N'Viettel Tower, 285 Cach Mang Thang Tam, District 10, HCMC'
UNION ALL SELECT @CompanyId4, N'Viettel Building, Giang Vo Street, Ba Dinh, Hanoi';
GO

DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');

INSERT INTO [JobSeeker] ([JobSeekerID], [FirstName], [LastName], [PhoneNumber], [Gender], [DateOfBirth], [CurrentLocation], [ExperienceLevel], [ProfileSummary], [CVFileURL])
SELECT @JobSeekerId1, N'Van A', N'Nguyen', N'+84901234567', N'MALE', N'1995-05-15', N'Ho Chi Minh City', N'Mid-Level',
 N'Experienced Full-stack Developer with 4+ years building scalable web applications using React, Node.js, and PostgreSQL. Strong problem-solving skills and passion for clean code.',
 N'https://storage.example.com/cv/nguyen-van-a.pdf'
UNION ALL
SELECT @JobSeekerId2, N'Thi B', N'Tran', N'+84912345678', N'FEMALE', N'1998-08-20', N'Hanoi', N'Entry-Level',
 N'Recent graduate with Bachelor degree in Computer Science. Specialized in Data Science and Machine Learning. Completed multiple projects using Python, TensorFlow, and scikit-learn.',
 N'https://storage.example.com/cv/tran-thi-b.pdf'
UNION ALL
SELECT @JobSeekerId3, N'Van C', N'Le', N'+84923456789', N'MALE', N'1992-03-10', N'Da Nang', N'Senior-Level',
 N'Senior Backend Engineer with 7+ years experience in Java, Spring Boot, and microservices architecture. Expert in system design, performance optimization, and leading technical teams.',
 N'https://storage.example.com/cv/le-van-c.pdf'
UNION ALL
SELECT @JobSeekerId4, N'Thi D', N'Pham', N'+84934567890', N'FEMALE', N'1996-11-25', N'Ho Chi Minh City', N'Mid-Level',
 N'DevOps Engineer with 3+ years expertise in AWS, Docker, Kubernetes, and CI/CD automation. Experienced in infrastructure as code using Terraform and building reliable deployment pipelines.',
 N'https://storage.example.com/cv/pham-thi-d.pdf'
UNION ALL
SELECT @JobSeekerId5, N'Van E', N'Hoang', N'+84945678901', N'MALE', N'1994-07-08', N'Hanoi', N'Mid-Level',
 N'Mobile Developer specializing in React Native and Flutter. Built 15+ production mobile apps with 1M+ downloads. Strong focus on UI/UX and app performance optimization.',
 N'https://storage.example.com/cv/hoang-van-e.pdf';
GO

INSERT INTO [Skill] ([SkillName], [SkillCategory], [PopularityScore]) VALUES
(N'Java', N'Programming Language', 0),
(N'Python', N'Programming Language', 0),
(N'JavaScript', N'Programming Language', 0),
(N'React', N'Frontend Framework', 0),
(N'Node.js', N'Backend Framework', 0),
(N'Spring Boot', N'Backend Framework', 0),
(N'MySQL', N'Database', 0),
(N'PostgreSQL', N'Database', 0),
(N'AWS', N'Cloud Platform', 0),
(N'Docker', N'DevOps Tool', 0),
(N'Kubernetes', N'DevOps Tool', 0),
(N'Machine Learning', N'AI/ML', 0),
(N'TensorFlow', N'AI/ML', 0),
(N'React Native', N'Mobile Development', 0),
(N'Flutter', N'Mobile Development', 0);
GO

-- Step 8: Insert JobSeeker Skills
DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');

INSERT INTO [JobSeekerSkill] ([JobSeekerID], [SkillID], [ProficiencyLevel], [YearOfExperience])
SELECT @JobSeekerId1, 3, N'Expert', 4.0
UNION ALL SELECT @JobSeekerId1, 4, N'Expert', 4.0
UNION ALL SELECT @JobSeekerId1, 5, N'Advanced', 3.5
UNION ALL SELECT @JobSeekerId1, 8, N'Advanced', 3.0
UNION ALL SELECT @JobSeekerId2, 2, N'Intermediate', 1.5
UNION ALL SELECT @JobSeekerId2, 12, N'Intermediate', 1.0
UNION ALL SELECT @JobSeekerId2, 13, N'Beginner', 1.0
UNION ALL SELECT @JobSeekerId3, 1, N'Expert', 7.0
UNION ALL SELECT @JobSeekerId3, 6, N'Expert', 6.5
UNION ALL SELECT @JobSeekerId3, 7, N'Advanced', 7.0
UNION ALL SELECT @JobSeekerId3, 8, N'Advanced', 5.0
UNION ALL SELECT @JobSeekerId3, 10, N'Advanced', 4.0
UNION ALL SELECT @JobSeekerId4, 9, N'Expert', 3.5
UNION ALL SELECT @JobSeekerId4, 10, N'Expert', 3.5
UNION ALL SELECT @JobSeekerId4, 11, N'Advanced', 2.5
UNION ALL SELECT @JobSeekerId4, 2, N'Advanced', 3.0
UNION ALL SELECT @JobSeekerId5, 3, N'Expert', 4.0
UNION ALL SELECT @JobSeekerId5, 4, N'Advanced', 3.5
UNION ALL SELECT @JobSeekerId5, 14, N'Expert', 3.0
UNION ALL SELECT @JobSeekerId5, 15, N'Intermediate', 1.5;
GO

DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [Job] ([CompanyID], [JobTitle], [JobDescription], [EmploymentType], [ExperienceRequired], [SalaryMin], [SalaryMax], [Location], [OpeningCount], [ApplicationDeadline], [JobStatus], [PostedDate])
SELECT @CompanyId1, N'Senior Java Developer', 
 N'Join our team to develop enterprise solutions for global clients. You will work on large-scale systems using Java, Spring Boot, and microservices architecture. Requirements: 5+ years Java experience, strong knowledge of design patterns, RESTful APIs, and database optimization.',
 N'FullTime', 5, 2500.00, 4000.00, N'Ho Chi Minh City', 3, N'2025-12-31 23:59:59', N'Open', N'2024-11-01 09:00:00'
UNION ALL
SELECT @CompanyId2, N'Data Scientist', 
 N'Develop machine learning models for gaming analytics and user behavior prediction. Work with big data, Python, TensorFlow, and cloud platforms. Requirements: 2+ years experience in data science, strong statistical knowledge, and passion for gaming industry.',
 N'FullTime', 2, 2000.00, 3500.00, N'Ho Chi Minh City', 2, N'2025-11-30 23:59:59', N'Open', N'2024-11-05 10:00:00'
UNION ALL
SELECT @CompanyId3, N'Full-stack Developer', 
 N'Build and maintain banking applications using React, Node.js, and PostgreSQL. Ensure security, scalability, and excellent user experience. Requirements: 3+ years full-stack experience, knowledge of fintech regulations, and attention to detail.',
 N'FullTime', 3, 2200.00, 3800.00, N'Hanoi', 4, N'2025-12-15 23:59:59', N'Open', N'2024-11-08 11:00:00'
UNION ALL
SELECT @CompanyId4, N'DevOps Engineer', 
 N'Manage cloud infrastructure and implement CI/CD pipelines for telecommunications services. Work with AWS, Docker, Kubernetes, and Terraform. Requirements: 3+ years DevOps experience, AWS certification preferred, strong automation skills.',
 N'FullTime', 3, 2400.00, 4200.00, N'Ho Chi Minh City', 2, N'2026-01-15 23:59:59', N'Open', N'2024-11-10 14:00:00'
UNION ALL
SELECT @CompanyId1, N'Backend Developer (Spring Boot)', 
 N'Build scalable microservices using Spring Boot for international projects. Requirements: 4+ years Java/Spring Boot experience, knowledge of message queues, caching strategies, and API design best practices.',
 N'FullTime', 4, 2300.00, 3800.00, N'Hanoi', 2, N'2026-01-31 23:59:59', N'Open', N'2024-11-12 15:00:00'
UNION ALL
SELECT @CompanyId2, N'Mobile Developer (React Native)', 
 N'Develop cross-platform mobile applications for our digital services. Requirements: 3+ years React Native experience, published apps on App Store/Google Play, strong UI/UX skills, and performance optimization expertise.',
 N'FullTime', 3, 2000.00, 3500.00, N'Ho Chi Minh City', 2, N'2025-12-20 23:59:59', N'Open', N'2024-11-15 16:00:00';
GO


DECLARE @Job1 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Senior Java Developer' ORDER BY PostedDate);
DECLARE @Job2 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Data Scientist' ORDER BY PostedDate);
DECLARE @Job3 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Full-stack Developer' ORDER BY PostedDate);
DECLARE @Job4 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'DevOps Engineer' ORDER BY PostedDate);
DECLARE @Job5 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Backend Developer (Spring Boot)' ORDER BY PostedDate);
DECLARE @Job6 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Mobile Developer (React Native)' ORDER BY PostedDate);

INSERT INTO [JobRequireSkill] ([JobID], [SkillID], [ProficiencyLevel], [IsRequired])
SELECT @Job1, 1, N'Expert', 1
UNION ALL SELECT @Job1, 6, N'Expert', 1
UNION ALL SELECT @Job1, 7, N'Advanced', 1
UNION ALL SELECT @Job1, 10, N'Intermediate', 0
UNION ALL SELECT @Job2, 2, N'Advanced', 1
UNION ALL SELECT @Job2, 12, N'Advanced', 1
UNION ALL SELECT @Job2, 13, N'Intermediate', 1
UNION ALL SELECT @Job2, 8, N'Intermediate', 0
UNION ALL SELECT @Job3, 3, N'Advanced', 1
UNION ALL SELECT @Job3, 4, N'Advanced', 1
UNION ALL SELECT @Job3, 5, N'Advanced', 1
UNION ALL SELECT @Job3, 8, N'Advanced', 1
UNION ALL SELECT @Job3, 10, N'Intermediate', 0
UNION ALL SELECT @Job4, 9, N'Expert', 1
UNION ALL SELECT @Job4, 10, N'Expert', 1
UNION ALL SELECT @Job4, 11, N'Advanced', 1
UNION ALL SELECT @Job4, 2, N'Advanced', 0
UNION ALL SELECT @Job5, 1, N'Expert', 1
UNION ALL SELECT @Job5, 6, N'Expert', 1
UNION ALL SELECT @Job5, 7, N'Advanced', 1
UNION ALL SELECT @Job5, 8, N'Advanced', 0
UNION ALL SELECT @Job5, 10, N'Intermediate', 0
UNION ALL SELECT @Job6, 3, N'Expert', 1
UNION ALL SELECT @Job6, 14, N'Expert', 1
UNION ALL SELECT @Job6, 4, N'Advanced', 0
UNION ALL SELECT @Job6, 15, N'Intermediate', 0;
GO

DECLARE @Job1 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Senior Java Developer' ORDER BY PostedDate);
DECLARE @Job2 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Data Scientist' ORDER BY PostedDate);
DECLARE @Job3 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Full-stack Developer' ORDER BY PostedDate);
DECLARE @Job4 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'DevOps Engineer' ORDER BY PostedDate);
DECLARE @Job5 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Backend Developer (Spring Boot)' ORDER BY PostedDate);
DECLARE @Job6 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Mobile Developer (React Native)' ORDER BY PostedDate);

INSERT INTO [JobMetrics] ([JobMetricID], [AppliedCount], [LikeCount], [ViewCount])
SELECT @Job1, 0, 15, 120
UNION ALL SELECT @Job2, 0, 12, 95
UNION ALL SELECT @Job3, 0, 18, 145
UNION ALL SELECT @Job4, 0, 10, 88
UNION ALL SELECT @Job5, 0, 14, 102
UNION ALL SELECT @Job6, 0, 16, 110;
GO


DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @Job1 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Senior Java Developer' ORDER BY PostedDate);
DECLARE @Job2 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Data Scientist' ORDER BY PostedDate);
DECLARE @Job3 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Full-stack Developer' ORDER BY PostedDate);
DECLARE @Job4 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'DevOps Engineer' ORDER BY PostedDate);
DECLARE @Job5 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Backend Developer (Spring Boot)' ORDER BY PostedDate);
DECLARE @Job6 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Mobile Developer (React Native)' ORDER BY PostedDate);

INSERT INTO [Application] ([JobSeekerID], [JobID], [ApplicationDate], [ApplicationStatus], [CoverLetterURL], [InterviewDate], [InterviewNote])
SELECT @JobSeekerId1, @Job3, N'2024-11-09 10:00:00', N'Interview', N'https://storage.example.com/cover/app001.pdf', 
 N'2024-11-20 14:00:00', N'Strong technical skills, good communication'
UNION ALL
SELECT @JobSeekerId1, @Job6, N'2024-11-16 09:30:00', N'UnderReview', N'https://storage.example.com/cover/app002.pdf', 
 NULL, NULL
UNION ALL
SELECT @JobSeekerId2, @Job2, N'2024-11-06 11:00:00', N'Offered', N'https://storage.example.com/cover/app003.pdf',
 N'2024-11-18 10:00:00', N'Excellent academic background, enthusiastic learner'
UNION ALL
SELECT @JobSeekerId3, @Job1, N'2024-11-02 14:30:00', N'Interview', N'https://storage.example.com/cover/app004.pdf',
 N'2024-11-22 15:00:00', N'Very experienced, strong system design skills'
UNION ALL
SELECT @JobSeekerId3, @Job5, N'2024-11-13 16:00:00', N'Shortlisted', N'https://storage.example.com/cover/app005.pdf',
 NULL, NULL
UNION ALL
SELECT @JobSeekerId4, @Job4, N'2024-11-11 13:00:00', N'Interview', N'https://storage.example.com/cover/app006.pdf',
 N'2024-11-25 11:00:00', N'Strong AWS and Kubernetes experience'
UNION ALL
SELECT @JobSeekerId5, @Job6, N'2024-11-16 10:00:00', N'UnderReview', N'https://storage.example.com/cover/app007.pdf',
 NULL, NULL
UNION ALL
SELECT @JobSeekerId2, @Job3, N'2024-11-14 12:00:00', N'Rejected', N'https://storage.example.com/cover/app008.pdf',
 NULL, N'Insufficient experience in full-stack development';
GO


DECLARE @Job1 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Senior Java Developer' ORDER BY PostedDate);
DECLARE @Job2 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Data Scientist' ORDER BY PostedDate);
DECLARE @Job3 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Full-stack Developer' ORDER BY PostedDate);
DECLARE @Job4 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'DevOps Engineer' ORDER BY PostedDate);
DECLARE @Job5 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Backend Developer (Spring Boot)' ORDER BY PostedDate);
DECLARE @Job6 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Mobile Developer (React Native)' ORDER BY PostedDate);

UPDATE [JobMetrics]
SET [AppliedCount] = (
    SELECT COUNT(*) FROM [Application] WHERE [JobID] = [JobMetricID]
)
WHERE [JobMetricID] IN (@Job1, @Job2, @Job3, @Job4, @Job5, @Job6);
GO

DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [Experience] ([JobSeekerID], [CompanyID], [JobTitle], [ExperienceType], [StartDate], [EndDate], [Description])
SELECT @JobSeekerId1, @CompanyId1, N'Full-stack Developer', N'FullTime', N'2020-06-01', N'2024-02-28',
 N'Developed and maintained web applications using React and Node.js. Collaborated with cross-functional teams to deliver high-quality software solutions.'
UNION ALL
SELECT @JobSeekerId1, @CompanyId2, N'Junior Web Developer', N'FullTime', N'2019-03-15', N'2020-05-31',
 N'Built responsive web interfaces and implemented RESTful APIs. Gained experience in Agile development methodology.'
UNION ALL
SELECT @JobSeekerId2, @CompanyId1, N'Data Science Intern', N'Internship', N'2023-06-01', N'2023-12-31',
 N'Analyzed large datasets using Python and machine learning algorithms. Created data visualizations and predictive models for business insights.'
UNION ALL
SELECT @JobSeekerId3, @CompanyId3, N'Senior Backend Engineer', N'FullTime', N'2020-01-01', NULL,
 N'Leading backend development team. Architected microservices infrastructure and mentored junior developers. Implemented CI/CD pipelines and optimized database performance.'
UNION ALL
SELECT @JobSeekerId3, @CompanyId1, N'Backend Developer', N'FullTime', N'2017-07-01', N'2019-12-31',
 N'Developed enterprise Java applications using Spring Boot. Worked on payment processing systems and financial transaction management.'
UNION ALL
SELECT @JobSeekerId3, @CompanyId2, N'Junior Java Developer', N'FullTime', N'2015-09-01', N'2017-06-30',
 N'Built RESTful APIs and integrated third-party services. Learned best practices in software engineering and code quality.'
UNION ALL
SELECT @JobSeekerId4, @CompanyId4, N'DevOps Engineer', N'FullTime', N'2021-03-01', NULL,
 N'Managing AWS infrastructure and implementing automated deployment pipelines. Reduced deployment time by 60% through automation.'
UNION ALL
SELECT @JobSeekerId4, @CompanyId1, N'Junior DevOps Engineer', N'FullTime', N'2019-06-01', N'2021-02-28',
 N'Assisted in cloud migration projects. Implemented monitoring and logging solutions using ELK stack.'
UNION ALL
SELECT @JobSeekerId5, @CompanyId2, N'Mobile Developer', N'FullTime', N'2020-08-01', NULL,
 N'Developing cross-platform mobile applications using React Native and Flutter. Published 10+ apps with excellent user ratings.'
UNION ALL
SELECT @JobSeekerId5, @CompanyId1, N'Mobile Developer Intern', N'Internship', N'2019-06-01', N'2020-07-31',
 N'Learned mobile development fundamentals. Contributed to feature development and bug fixes in production apps.';
GO

DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [ReviewCompany] ([JobSeekerID], [CompanyID], [ReviewTitle], [ReviewDate], [ReviewText], [Rating], [VerificationStatus], [IsAnonymous])
SELECT @JobSeekerId1, @CompanyId1, N'Great place to grow your career', N'2024-03-15 10:00:00',
 N'FPT Software provides excellent learning opportunities and supportive team environment. Good salary and benefits. Work-life balance could be better during peak project times.',
 4, N'Verified', 0
UNION ALL
SELECT @JobSeekerId1, @CompanyId2, N'Innovative and fun workplace', N'2024-03-20 14:30:00',
 N'VNG has a young, dynamic culture with cutting-edge technology. Great office facilities and team activities. Management is open to new ideas.',
 5, N'Verified', 0
UNION ALL
SELECT @JobSeekerId3, @CompanyId3, N'Excellent fintech company', N'2024-04-10 09:00:00',
 N'Techcombank offers competitive compensation and modern working environment. Challenging projects in banking technology. Great career development opportunities.',
 5, N'Verified', 1
UNION ALL
SELECT @JobSeekerId3, @CompanyId1, N'Good company for Java developers', N'2024-04-15 16:00:00',
 N'Strong technical team with experienced seniors. Good training programs and project exposure. Salary is competitive for the market.',
 4, N'Verified', 1
UNION ALL
SELECT @JobSeekerId4, @CompanyId4, N'Leading telecom with good infrastructure', N'2024-05-01 11:00:00',
 N'Viettel provides stable career path and comprehensive benefits. Good for learning telecom and cloud technologies. Large organization with structured processes.',
 4, N'Verified', 0
UNION ALL
SELECT @JobSeekerId4, @CompanyId1, N'Great for learning DevOps', N'2024-05-10 13:00:00',
 N'FPT has many international projects which provide good exposure. DevOps practices are well-established. Good mentorship from senior engineers.',
 4, N'Verified', 1
UNION ALL
SELECT @JobSeekerId5, @CompanyId2, N'Best place for mobile developers', N'2024-06-01 10:30:00',
 N'VNG invests heavily in mobile technology. You will work on products with millions of users. Great team collaboration and modern tech stack.',
 5, N'Verified', 0;
GO


DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [SocialProfile] ([OwnerId], [ProfileType], [URL])
SELECT @JobSeekerId1, N'LinkedIn', N'https://linkedin.com/in/nguyen-van-a'
UNION ALL SELECT @JobSeekerId1, N'GitHub', N'https://github.com/nguyenvana'
UNION ALL SELECT @JobSeekerId1, N'Portfolio', N'https://nguyenvana.dev'
UNION ALL SELECT @JobSeekerId2, N'LinkedIn', N'https://linkedin.com/in/tran-thi-b'
UNION ALL SELECT @JobSeekerId2, N'GitHub', N'https://github.com/tranthib'
UNION ALL SELECT @JobSeekerId3, N'LinkedIn', N'https://linkedin.com/in/le-van-c'
UNION ALL SELECT @JobSeekerId3, N'GitHub', N'https://github.com/levanc'
UNION ALL SELECT @JobSeekerId3, N'Portfolio', N'https://levanc.tech'
UNION ALL SELECT @JobSeekerId4, N'LinkedIn', N'https://linkedin.com/in/pham-thi-d'
UNION ALL SELECT @JobSeekerId4, N'GitHub', N'https://github.com/phamthid'
UNION ALL SELECT @JobSeekerId5, N'LinkedIn', N'https://linkedin.com/in/hoang-van-e'
UNION ALL SELECT @JobSeekerId5, N'GitHub', N'https://github.com/hoangvane'
UNION ALL SELECT @JobSeekerId5, N'Portfolio', N'https://hoangvane.com'
UNION ALL SELECT @CompanyId1, N'LinkedIn', N'https://linkedin.com/company/fpt-software'
UNION ALL SELECT @CompanyId1, N'Facebook', N'https://facebook.com/fptsoftware'
UNION ALL SELECT @CompanyId2, N'LinkedIn', N'https://linkedin.com/company/vng-corporation'
UNION ALL SELECT @CompanyId2, N'Facebook', N'https://facebook.com/vngcorp'
UNION ALL SELECT @CompanyId3, N'LinkedIn', N'https://linkedin.com/company/techcombank'
UNION ALL SELECT @CompanyId3, N'Facebook', N'https://facebook.com/techcombank'
UNION ALL SELECT @CompanyId4, N'LinkedIn', N'https://linkedin.com/company/viettel-group'
UNION ALL SELECT @CompanyId4, N'Facebook', N'https://facebook.com/viettelgroup';
GO


DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [Follow] ([FollowerID], [FolloweeID], [FollowDate])
SELECT @JobSeekerId1, @CompanyId1, N'2024-03-02 08:00:00'
UNION ALL SELECT @JobSeekerId1, @CompanyId2, N'2024-03-03 09:00:00'
UNION ALL SELECT @JobSeekerId1, @CompanyId3, N'2024-03-05 10:00:00'
UNION ALL SELECT @JobSeekerId2, @CompanyId1, N'2024-03-06 11:00:00'
UNION ALL SELECT @JobSeekerId2, @CompanyId2, N'2024-03-07 12:00:00'
UNION ALL SELECT @JobSeekerId3, @CompanyId1, N'2024-03-11 08:30:00'
UNION ALL SELECT @JobSeekerId3, @CompanyId3, N'2024-03-12 09:30:00'
UNION ALL SELECT @JobSeekerId3, @CompanyId4, N'2024-03-13 10:30:00'
UNION ALL SELECT @JobSeekerId4, @CompanyId4, N'2024-03-16 11:30:00'
UNION ALL SELECT @JobSeekerId4, @CompanyId1, N'2024-03-17 12:30:00'
UNION ALL SELECT @JobSeekerId5, @CompanyId2, N'2024-03-21 08:45:00'
UNION ALL SELECT @JobSeekerId5, @CompanyId1, N'2024-03-22 09:45:00';
GO


DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [DepartmentContact] ([CompanyID], [ContactEmail], [ContactName], [ContactPhone], [ContactRole], [Department])
SELECT @CompanyId1, N'hr@fpt.com.vn', N'Nguyen Thi Mai', N'+84281234567', N'HR Manager', N'Human Resources'
UNION ALL SELECT @CompanyId1, N'tech.recruitment@fpt.com.vn', N'Tran Van Hoang', N'+84281234568', N'Technical Recruiter', N'Talent Acquisition'
UNION ALL SELECT @CompanyId1, N'it.support@fpt.com.vn', N'Le Thi Lan', N'+84281234569', N'IT Support Lead', N'Information Technology'
UNION ALL SELECT @CompanyId2, N'recruitment@vng.com.vn', N'Pham Van Duc', N'+84282345678', N'Recruitment Lead', N'Human Resources'
UNION ALL SELECT @CompanyId2, N'tech.hiring@vng.com.vn', N'Hoang Thi Nga', N'+84282345679', N'Tech Talent Partner', N'Engineering'
UNION ALL SELECT @CompanyId3, N'talent@techcombank.com.vn', N'Vu Van Thanh', N'+84243456789', N'Talent Acquisition Manager', N'Human Resources'
UNION ALL SELECT @CompanyId3, N'it.recruitment@techcombank.com.vn', N'Nguyen Thi Huong', N'+84243456790', N'IT Recruiter', N'Technology'
UNION ALL SELECT @CompanyId4, N'hr@viettel.com.vn', N'Dang Van Minh', N'+84284567890', N'HR Director', N'Human Resources'
UNION ALL SELECT @CompanyId4, N'tech.jobs@viettel.com.vn', N'Bui Thi Thao', N'+84284567891', N'Technical Recruiter', N'Technology Division';
GO


INSERT INTO [Notification] ([NotificationType], [NotificationContent], [SendDate], [ReadStatus], [DeliveryMethod])
SELECT N'Application', N'Your application for Senior Java Developer at FPT Software has been received', N'2024-11-02 14:35:00', 1, N'InApp'
UNION ALL SELECT N'Interview', N'You have been scheduled for an interview for Full-stack Developer position at Techcombank', N'2024-11-10 09:00:00', 1, N'Email'
UNION ALL SELECT N'Offer', N'Congratulations! You have received a job offer for Data Scientist position at VNG Corporation', N'2024-11-19 10:00:00', 1, N'Email'
UNION ALL SELECT N'Interview', N'Interview reminder: Your interview for DevOps Engineer at Viettel is tomorrow at 11:00 AM', N'2024-11-24 09:00:00', 0, N'InApp'
UNION ALL SELECT N'Application', N'New application received for Mobile Developer (React Native) position', N'2024-11-16 10:05:00', 1, N'InApp'
UNION ALL SELECT N'System', N'Welcome to TechTalentHub! Complete your profile to get better job recommendations', N'2024-03-01 08:05:00', 1, N'InApp'
UNION ALL SELECT N'System', N'Your company profile has been verified successfully', N'2024-02-02 11:00:00', 1, N'Email'
UNION ALL SELECT N'Message', N'You have a new message from FPT Software HR team', N'2024-11-15 14:30:00', 0, N'InApp';
GO


DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');

INSERT INTO [ReceiveNotification] ([NotificationID], [ReceiverID])
SELECT 1, @JobSeekerId3  -- Application received notification
UNION ALL SELECT 2, @JobSeekerId1  -- Interview schedule notification
UNION ALL SELECT 3, @JobSeekerId2  -- Job offer notification
UNION ALL SELECT 4, @JobSeekerId4  -- Interview reminder notification
UNION ALL SELECT 5, @CompanyId2  -- New application received
UNION ALL SELECT 6, @JobSeekerId1  -- Welcome notification
UNION ALL SELECT 6, @JobSeekerId2
UNION ALL SELECT 6, @JobSeekerId3
UNION ALL SELECT 6, @JobSeekerId4
UNION ALL SELECT 6, @JobSeekerId5
UNION ALL SELECT 7, @CompanyId1  -- Profile verified notification
UNION ALL SELECT 8, @JobSeekerId1;  -- New message notification
GO

DECLARE @AdminId NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'admin@techtalenthub.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');

INSERT INTO [AuditLog] ([ActorID], [ActionType], [Timestamp], [Detailed], [IPAddress])
SELECT @AdminId, N'SYSTEM_INIT', N'2024-01-15 09:00:00', N'System initialized and admin account created', N'127.0.0.1'
UNION ALL SELECT @AdminId, N'COMPANY_VERIFICATION', N'2024-02-02 11:00:00', N'Verified company: FPT Software', N'192.168.1.100'
UNION ALL SELECT @AdminId, N'COMPANY_VERIFICATION', N'2024-02-06 10:00:00', N'Verified company: VNG Corporation', N'192.168.1.100'
UNION ALL SELECT @AdminId, N'COMPANY_VERIFICATION', N'2024-02-11 09:00:00', N'Verified company: Techcombank', N'192.168.1.100'
UNION ALL SELECT @AdminId, N'COMPANY_VERIFICATION', N'2024-02-16 14:00:00', N'Verified company: Viettel Group', N'192.168.1.100'
UNION ALL SELECT @CompanyId1, N'JOB_POSTED', N'2024-11-01 09:00:00', N'Posted job: Senior Java Developer', N'118.69.80.123'
UNION ALL SELECT @CompanyId2, N'JOB_POSTED', N'2024-11-05 10:00:00', N'Posted job: Data Scientist', N'118.69.80.124'
UNION ALL SELECT @CompanyId1, N'APPLICATION_REVIEWED', N'2024-11-03 14:00:00', N'Reviewed application from Le Van C', N'118.69.80.123';
GO


SELECT 'Users' AS [Table], COUNT(*) AS [Row Count] FROM [User]
UNION ALL SELECT 'Admins', COUNT(*) FROM [Admin]
UNION ALL SELECT 'Companies', COUNT(*) FROM [Company]
UNION ALL SELECT 'Company Locations', COUNT(*) FROM [CompanyLocation]
UNION ALL SELECT 'Job Seekers', COUNT(*) FROM [JobSeeker]
UNION ALL SELECT 'Skills', COUNT(*) FROM [Skill]
UNION ALL SELECT 'JobSeeker Skills', COUNT(*) FROM [JobSeekerSkill]
UNION ALL SELECT 'Experiences', COUNT(*) FROM [Experience]
UNION ALL SELECT 'Jobs', COUNT(*) FROM [Job]
UNION ALL SELECT 'Job Required Skills', COUNT(*) FROM [JobRequireSkill]
UNION ALL SELECT 'Applications', COUNT(*) FROM [Application]
UNION ALL SELECT 'Company Reviews', COUNT(*) FROM [ReviewCompany]
UNION ALL SELECT 'Job Metrics', COUNT(*) FROM [JobMetrics]
UNION ALL SELECT 'Social Profiles', COUNT(*) FROM [SocialProfile]
UNION ALL SELECT 'Follows', COUNT(*) FROM [Follow]
UNION ALL SELECT 'Department Contacts', COUNT(*) FROM [DepartmentContact]
UNION ALL SELECT 'Notifications', COUNT(*) FROM [Notification]
UNION ALL SELECT 'Receive Notifications', COUNT(*) FROM [ReceiveNotification]
UNION ALL SELECT 'Audit Logs', COUNT(*) FROM [AuditLog]
ORDER BY [Table];

PRINT '';
PRINT 'All sample data has been inserted successfully!';
PRINT 'Database is ready for testing and development.';
PRINT '';
GO