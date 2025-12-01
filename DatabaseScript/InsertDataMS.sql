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

INSERT INTO [Admin] ([AdminId], [AdminName], [AdminRole], [DateAssigned]) VALUES
(N'US001', N'System Administrator', N'SuperAdmin', N'2024-01-15 09:00:00');
GO

INSERT INTO [Company] ([CompanyID], [CompanyName], [FounderYear], [CompanySize], [Industry], [CompanyDescription], [CompanyWebsite], [VerificationStatus], [LogoURL]) VALUES
(N'US002', N'FPT Software', 1999, N'Enterprise', N'Information Technology', 
 N'Leading software outsourcing company in Vietnam with over 30,000 employees worldwide. Specializing in digital transformation, AI, cloud computing, and enterprise solutions.',
 N'https://fptsoftware.com', N'ACCEPTED', N'https://fptsoftware.com/logo.png'),
(N'US003', N'VNG Corporation', 2004, N'Large', N'Technology & Entertainment',
 N'Pioneer in online games, digital content, and e-commerce platforms in Vietnam. Creator of Zalo, Vietnam''s leading messaging app with over 70 million users.',
 N'https://vng.com.vn', N'ACCEPTED', N'https://vng.com.vn/logo.png'),
(N'US004', N'Vietnam Technological and Commercial Joint Stock Bank', 1993, N'Large', N'Banking & Finance',
 N'One of the leading commercial banks in Vietnam with cutting-edge fintech solutions. Recognized for innovation in digital banking and customer experience.',
 N'https://techcombank.com.vn', N'ACCEPTED', N'https://techcombank.com.vn/logo.png'),
(N'US005', N'Viettel Group', 1989, N'Enterprise', N'Telecommunications',
 N'Largest telecommunications company in Vietnam providing mobile, internet, and digital services. Expanding into AI, IoT, cloud computing, and cybersecurity solutions.',
 N'https://viettel.com.vn', N'ACCEPTED', N'https://viettel.com.vn/logo.png');
GO

INSERT INTO [CompanyLocation] ([CompanyID], [Address]) VALUES
(N'US002', N'FPT Building, Tan Thuan Export Processing Zone, District 7, Ho Chi Minh City'),
(N'US002', N'FPT Tower, Duy Tan Street, Cau Giay District, Hanoi'),
(N'US003', N'VNG Campus, Z06 Street, Tan Thuan EPZ, District 7, Ho Chi Minh City'),
(N'US003', N'VNG Hanoi Office, Keangnam Landmark 72, Pham Hung Street, Hanoi'),
(N'US004', N'Techcombank Tower, 191 Ba Trieu, Hai Ba Trung District, Hanoi'),
(N'US004', N'162-164 Pasteur, Ben Nghe Ward, District 1, Ho Chi Minh City'),
(N'US005', N'Viettel Tower, 285 Cach Mang Thang Tam, District 10, Ho Chi Minh City'),
(N'US005', N'Viettel Building, Giang Vo Street, Ba Dinh District, Hanoi');
GO

INSERT INTO [JobSeeker] ([JobSeekerID], [FirstName], [LastName], [PhoneNumber], [Gender], [DateOfBirth], [CurrentLocation], [ExperienceLevel], [ProfileSummary], [CVFileURL]) VALUES
(N'US006', N'Van A', N'Nguyen', N'+84901234567', N'MALE', N'1995-05-15', N'Ho Chi Minh City', N'Mid-Level',
 N'Experienced Full-stack Developer with 4+ years building scalable web applications using React, Node.js, and PostgreSQL. Strong problem-solving skills and passion for clean code.',
 N'https://storage.example.com/cv/nguyen-van-a.pdf'),
(N'US007', N'Thi B', N'Tran', N'+84912345678', N'FEMALE', N'1998-08-20', N'Hanoi', N'Entry-Level',
 N'Recent graduate with Bachelor degree in Computer Science. Specialized in Data Science and Machine Learning. Completed multiple projects using Python, TensorFlow, and scikit-learn.',
 N'https://storage.example.com/cv/tran-thi-b.pdf'),
(N'US008', N'Van C', N'Le', N'+84923456789', N'MALE', N'1992-03-10', N'Da Nang', N'Senior-Level',
 N'Senior Backend Engineer with 7+ years experience in Java, Spring Boot, and microservices architecture. Expert in system design, performance optimization, and leading technical teams.',
 N'https://storage.example.com/cv/le-van-c.pdf'),
(N'US009', N'Thi D', N'Pham', N'+84934567890', N'FEMALE', N'1996-11-25', N'Ho Chi Minh City', N'Mid-Level',
 N'DevOps Engineer with 3+ years expertise in AWS, Docker, Kubernetes, and CI/CD automation. Experienced in infrastructure as code using Terraform and building reliable deployment pipelines.',
 N'https://storage.example.com/cv/pham-thi-d.pdf'),
(N'US010', N'Van E', N'Hoang', N'+84945678901', N'MALE', N'1994-07-08', N'Hanoi', N'Mid-Level',
 N'Mobile Developer specializing in React Native and Flutter. Built 15+ production mobile apps with 1M+ downloads. Strong focus on UI/UX and app performance optimization.',
 N'https://storage.example.com/cv/hoang-van-e.pdf');
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

INSERT INTO [JobSeekerSkill] ([JobSeekerID], [SkillID], [ProficiencyLevel], [YearOfExperience]) VALUES
(N'US006', 3, N'Expert', 4.0),
(N'US006', 4, N'Expert', 4.0),
(N'US006', 5, N'Advanced', 3.5),
(N'US006', 8, N'Advanced', 3.0),
(N'US007', 2, N'Intermediate', 1.5),
(N'US007', 12, N'Intermediate', 1.0),
(N'US007', 13, N'Beginner', 1.0),
(N'US008', 1, N'Expert', 7.0),
(N'US008', 6, N'Expert', 6.5),
(N'US008', 7, N'Advanced', 7.0),
(N'US008', 8, N'Advanced', 5.0),
(N'US008', 10, N'Advanced', 4.0),
(N'US009', 9, N'Expert', 3.5),
(N'US009', 10, N'Expert', 3.5),
(N'US009', 11, N'Advanced', 2.5),
(N'US009', 2, N'Advanced', 3.0),
(N'US010', 3, N'Expert', 4.0),
(N'US010', 4, N'Advanced', 3.5),
(N'US010', 14, N'Expert', 3.0),
(N'US010', 15, N'Intermediate', 1.5);
GO

INSERT INTO [Job] ([CompanyID], [JobTitle], [JobDescription], [EmploymentType], [ExperienceRequired], [SalaryMin], [SalaryMax], [Location], [OpeningCount], [ApplicationDeadline], [JobStatus], [PostedDate]) VALUES
(N'US002', N'Senior Java Developer', 
 N'Join our team to develop enterprise solutions for global clients. You will work on large-scale systems using Java, Spring Boot, and microservices architecture. Requirements: 5+ years Java experience, strong knowledge of design patterns, RESTful APIs, and database optimization.',
 N'FullTime', 5, 2500.00, 4000.00, N'Ho Chi Minh City', 3, N'2025-12-31 23:59:59', N'Open', N'2024-11-01 09:00:00'),
(N'US003', N'Data Scientist', 
 N'Develop machine learning models for gaming analytics and user behavior prediction. Work with big data, Python, TensorFlow, and cloud platforms. Requirements: 2+ years experience in data science, strong statistical knowledge, and passion for gaming industry.',
 N'FullTime', 2, 2000.00, 3500.00, N'Ho Chi Minh City', 2, N'2025-11-30 23:59:59', N'Open', N'2024-11-05 10:00:00'),
(N'US004', N'Full-stack Developer', 
 N'Build and maintain banking applications using React, Node.js, and PostgreSQL. Ensure security, scalability, and excellent user experience. Requirements: 3+ years full-stack experience, knowledge of fintech regulations, and attention to detail.',
 N'FullTime', 3, 2200.00, 3800.00, N'Hanoi', 4, N'2025-12-15 23:59:59', N'Open', N'2024-11-08 11:00:00'),
(N'US005', N'DevOps Engineer', 
 N'Manage cloud infrastructure and implement CI/CD pipelines for telecommunications services. Work with AWS, Docker, Kubernetes, and Terraform. Requirements: 3+ years DevOps experience, AWS certification preferred, strong automation skills.',
 N'FullTime', 3, 2400.00, 4200.00, N'Ho Chi Minh City', 2, N'2026-01-15 23:59:59', N'Open', N'2024-11-10 14:00:00'),
(N'US002', N'Backend Developer (Spring Boot)', 
 N'Build scalable microservices using Spring Boot for international projects. Requirements: 4+ years Java/Spring Boot experience, knowledge of message queues, caching strategies, and API design best practices.',
 N'FullTime', 4, 2300.00, 3800.00, N'Hanoi', 2, N'2026-01-31 23:59:59', N'Open', N'2024-11-12 15:00:00'),
(N'US003', N'Mobile Developer (React Native)', 
 N'Develop cross-platform mobile applications for our digital services. Requirements: 3+ years React Native experience, published apps on App Store/Google Play, strong UI/UX skills, and performance optimization expertise.',
 N'FullTime', 3, 2000.00, 3500.00, N'Ho Chi Minh City', 2, N'2025-12-20 23:59:59', N'Open', N'2024-11-15 16:00:00');
GO

INSERT INTO [JobRequireSkill] ([JobID], [SkillID], [ProficiencyLevel], [IsRequired]) VALUES
(N'JOB001', 1, N'Expert', 1),
(N'JOB001', 6, N'Expert', 1),
(N'JOB001', 7, N'Advanced', 1),
(N'JOB001', 10, N'Intermediate', 0),
(N'JOB002', 2, N'Advanced', 1),
(N'JOB002', 12, N'Advanced', 1),
(N'JOB002', 13, N'Intermediate', 1),
(N'JOB002', 8, N'Intermediate', 0),
(N'JOB003', 3, N'Advanced', 1),
(N'JOB003', 4, N'Advanced', 1),
(N'JOB003', 5, N'Advanced', 1),
(N'JOB003', 8, N'Advanced', 1),
(N'JOB003', 10, N'Intermediate', 0),
(N'JOB004', 9, N'Expert', 1),
(N'JOB004', 10, N'Expert', 1),
(N'JOB004', 11, N'Advanced', 1),
(N'JOB004', 2, N'Advanced', 0),
(N'JOB005', 1, N'Expert', 1),
(N'JOB005', 6, N'Expert', 1),
(N'JOB005', 7, N'Advanced', 1),
(N'JOB005', 8, N'Advanced', 0),
(N'JOB005', 10, N'Intermediate', 0),
(N'JOB006', 3, N'Expert', 1),
(N'JOB006', 14, N'Expert', 1),
(N'JOB006', 4, N'Advanced', 0),
(N'JOB006', 15, N'Intermediate', 0);
GO

INSERT INTO [JobMetrics] ([JobMetricID], [AppliedCount], [LikeCount], [ViewCount]) VALUES
(N'JOB001', 0, 15, 120),
(N'JOB002', 0, 12, 95),
(N'JOB003', 0, 18, 145),
(N'JOB004', 0, 10, 88),
(N'JOB005', 0, 14, 102),
(N'JOB006', 0, 16, 110);
GO

INSERT INTO [Application] ([JobSeekerID], [JobID], [ApplicationDate], [ApplicationStatus], [CoverLetterURL], [InterviewDate], [InterviewNote]) VALUES
(N'US006', N'JOB003', N'2024-11-09 10:00:00', N'Interview', N'https://storage.example.com/cover/app001.pdf', 
 N'2024-11-20 14:00:00', N'Strong technical skills, good communication'),
(N'US006', N'JOB006', N'2024-11-16 09:30:00', N'UnderReview', N'https://storage.example.com/cover/app002.pdf', 
 NULL, NULL),
(N'US007', N'JOB002', N'2024-11-06 11:00:00', N'Offered', N'https://storage.example.com/cover/app003.pdf',
 N'2024-11-18 10:00:00', N'Excellent academic background, enthusiastic learner'),
(N'US008', N'JOB001', N'2024-11-02 14:30:00', N'Interview', N'https://storage.example.com/cover/app004.pdf',
 N'2024-11-22 15:00:00', N'Very experienced, strong system design skills'),
(N'US008', N'JOB005', N'2024-11-13 16:00:00', N'Shortlisted', N'https://storage.example.com/cover/app005.pdf',
 NULL, NULL),
(N'US009', N'JOB004', N'2024-11-11 13:00:00', N'Interview', N'https://storage.example.com/cover/app006.pdf',
 N'2024-11-25 11:00:00', N'Strong AWS and Kubernetes experience'),
(N'US010', N'JOB006', N'2024-11-16 10:00:00', N'UnderReview', N'https://storage.example.com/cover/app007.pdf',
 NULL, NULL),
(N'US007', N'JOB003', N'2024-11-14 12:00:00', N'Rejected', N'https://storage.example.com/cover/app008.pdf',
 NULL, N'Insufficient experience in full-stack development');
GO

UPDATE [JobMetrics] SET [AppliedCount] = 2 WHERE [JobMetricID] = N'JOB001';
UPDATE [JobMetrics] SET [AppliedCount] = 1 WHERE [JobMetricID] = N'JOB002';
UPDATE [JobMetrics] SET [AppliedCount] = 2 WHERE [JobMetricID] = N'JOB003';
UPDATE [JobMetrics] SET [AppliedCount] = 1 WHERE [JobMetricID] = N'JOB004';
UPDATE [JobMetrics] SET [AppliedCount] = 1 WHERE [JobMetricID] = N'JOB005';
UPDATE [JobMetrics] SET [AppliedCount] = 2 WHERE [JobMetricID] = N'JOB006';
GO

INSERT INTO [Experience] ([JobSeekerID], [CompanyID], [JobTitle], [ExperienceType], [StartDate], [EndDate], [Description]) VALUES
(N'US006', N'US002', N'Junior Full-stack Developer', N'FullTime', N'2020-06-01', N'2022-05-31',
 N'Developed web applications using React and Node.js. Collaborated with cross-functional teams to deliver high-quality software products.'),
(N'US006', N'US003', N'Full-stack Developer', N'FullTime', N'2022-06-01', NULL,
 N'Currently working on scalable web platforms serving millions of users. Implementing new features and optimizing application performance.'),
(N'US008', N'US002', N'Java Developer', N'FullTime', N'2017-03-01', N'2020-12-31',
 N'Built enterprise applications using Java and Spring framework. Participated in system architecture design and code reviews.'),
(N'US008', N'US004', N'Senior Backend Engineer', N'FullTime', N'2021-01-01', NULL,
 N'Leading backend development team for banking systems. Designing microservices architecture and ensuring system reliability.'),
(N'US009', N'US005', N'Junior DevOps Engineer', N'FullTime', N'2021-07-01', N'2023-06-30',
 N'Managed CI/CD pipelines and cloud infrastructure. Automated deployment processes and improved system monitoring.'),
(N'US009', N'US002', N'DevOps Engineer', N'FullTime', N'2023-07-01', NULL,
 N'Currently managing AWS infrastructure for multiple projects. Implementing infrastructure as code using Terraform and Kubernetes orchestration.');
GO

INSERT INTO [ReviewCompany] ([JobSeekerID], [CompanyID], [ReviewTitle], [ReviewText], [Rating], [VerificationStatus], [IsAnonymous], [ReviewDate]) VALUES
(N'US006', N'US002', N'Great place for career growth',
 N'FPT Software provides excellent learning opportunities and modern tech stack. The work environment is professional and supportive. Good salary and benefits package.',
 5, N'Verified', 0, N'2024-10-15 14:30:00'),
(N'US006', N'US003', N'Innovative and dynamic workplace',
 N'VNG has an amazing startup culture with focus on innovation. Great for young developers who want to work on consumer products. Work-life balance could be better during product launches.',
 4, N'Verified', 0, N'2024-10-20 16:00:00'),
(N'US008', N'US002', N'Solid company for experienced developers',
 N'Good projects with international clients. Professional development environment. However, sometimes bureaucracy can slow down decision making.',
 4, N'Verified', 1, N'2024-10-25 10:00:00'),
(N'US008', N'US004', N'Excellent fintech experience',
 N'Techcombank is leading in digital banking transformation. Challenging projects, competitive salary, and great benefits. Highly recommended for those interested in fintech.',
 5, N'Verified', 0, N'2024-11-01 11:30:00');
GO

INSERT INTO [Notification] ([NotificationType], [NotificationContent], [SendDate], [ReadStatus], [DeliveryMethod]) VALUES
(N'Application', N'Your application for Full-stack Developer at Techcombank has been received and is under review.', 
 N'2024-11-09 10:05:00', 1, N'Email'),
(N'Interview', N'Congratulations! You have been shortlisted for an interview for Data Scientist position at VNG Corporation.', 
 N'2024-11-10 09:00:00', 1, N'Email'),
(N'Offer', N'Great news! You have received a job offer for Data Scientist position at VNG Corporation.', 
 N'2024-11-19 10:00:00', 0, N'Email'),
(N'Interview', N'You have been invited for an interview for Senior Java Developer at FPT Software on Nov 22, 2024.', 
 N'2024-11-12 14:00:00', 1, N'InApp'),
(N'System', N'Welcome to TechTalentHub! Complete your profile to get better job recommendations.', 
 N'2024-11-01 08:00:00', 1, N'InApp');
GO

INSERT INTO [ReceiveNotification] ([NotificationID], [ReceiverID]) VALUES
(1, N'US006'),
(2, N'US007'),
(3, N'US007'),
(4, N'US008'),
(5, N'US006'),
(5, N'US007'),
(5, N'US008'),
(5, N'US009');
GO

INSERT INTO [Follow] ([FollowerID], [FolloweeID], [FollowDate]) VALUES
(N'US006', N'US002', N'2024-10-01 10:00:00'),
(N'US006', N'US003', N'2024-10-05 11:00:00'),
(N'US007', N'US003', N'2024-10-10 09:00:00'),
(N'US008', N'US002', N'2024-10-15 14:00:00'),
(N'US009', N'US005', N'2024-10-20 16:00:00');
GO

INSERT INTO [SocialProfile] ([OwnerId], [ProfileType], [URL]) VALUES
(N'US006', N'LinkedIn', N'https://linkedin.com/in/nguyen-van-a'),
(N'US006', N'GitHub', N'https://github.com/nguyenvana'),
(N'US007', N'LinkedIn', N'https://linkedin.com/in/tran-thi-b'),
(N'US007', N'GitHub', N'https://github.com/tranthib'),
(N'US008', N'LinkedIn', N'https://linkedin.com/in/le-van-c'),
(N'US008', N'GitHub', N'https://github.com/levanc'),
(N'US009', N'LinkedIn', N'https://linkedin.com/in/pham-thi-d'),
(N'US010', N'GitHub', N'https://github.com/hoangvane');
GO

INSERT INTO [AuditLog] ([ActorID], [ActionType], [Timestamp], [Detailed], [IPAddress]) VALUES
(N'US001', N'USER_LOGIN', N'2024-11-01 09:00:00', N'Admin logged in successfully', N'192.168.1.100'),
(N'US002', N'JOB_POST_CREATED', N'2024-11-01 09:30:00', N'Created job posting JOB001', N'192.168.1.101'),
(N'US006', N'APPLICATION_SUBMITTED', N'2024-11-09 10:00:00', N'Applied to job JOB003', N'192.168.1.102'),
(N'US007', N'APPLICATION_SUBMITTED', N'2024-11-06 11:00:00', N'Applied to job JOB002', N'192.168.1.103'),
(N'US002', N'APPLICATION_STATUS_UPDATED', N'2024-11-10 09:00:00', N'Updated application status to Interview', N'192.168.1.101'),
(N'US003', N'APPLICATION_STATUS_UPDATED', N'2024-11-19 10:00:00', N'Updated application status to Offered', N'192.168.1.104');
GO

INSERT INTO [DepartmentContact] ([CompanyID], [ContactEmail], [ContactName], [ContactPhone], [ContactRole], [Department]) VALUES
(N'US002', N'hr.recruitment@fpt.com.vn', N'Nguyen Thi Mai', N'+84281234567', N'Senior HR Manager', N'Human Resources'),
(N'US002', N'tech.lead@fpt.com.vn', N'Tran Van Hung', N'+84281234568', N'Technical Lead', N'Engineering'),
(N'US003', N'talent@vng.com.vn', N'Le Thi Lan', N'+84283456789', N'Talent Acquisition Manager', N'Human Resources'),
(N'US004', N'recruitment@techcombank.com.vn', N'Pham Van Minh', N'+84285678901', N'HR Director', N'Human Resources'),
(N'US005', N'hr.tech@viettel.com.vn', N'Hoang Thi Nga', N'+84287890123', N'Technical Recruiter', N'Human Resources'),
(N'US005', N'devops.manager@viettel.com.vn', N'Nguyen Van Duc', N'+84287890124', N'DevOps Manager', N'Engineering');
GO

SELECT N'Data insertion completed successfully!' AS Status;
GO

SELECT N'User' AS TableName, COUNT(*) AS Row_Count FROM [User]
UNION ALL SELECT N'Admin', COUNT(*) FROM [Admin]
UNION ALL SELECT N'Company', COUNT(*) FROM [Company]
UNION ALL SELECT N'CompanyLocation', COUNT(*) FROM [CompanyLocation]
UNION ALL SELECT N'JobSeeker', COUNT(*) FROM [JobSeeker]
UNION ALL SELECT N'Skill', COUNT(*) FROM [Skill]
UNION ALL SELECT N'JobSeekerSkill', COUNT(*) FROM [JobSeekerSkill]
UNION ALL SELECT N'Experience', COUNT(*) FROM [Experience]
UNION ALL SELECT N'Job', COUNT(*) FROM [Job]
UNION ALL SELECT N'JobRequireSkill', COUNT(*) FROM [JobRequireSkill]
UNION ALL SELECT N'JobMetrics', COUNT(*) FROM [JobMetrics]
UNION ALL SELECT N'Application', COUNT(*) FROM [Application]
UNION ALL SELECT N'ReviewCompany', COUNT(*) FROM [ReviewCompany]
UNION ALL SELECT N'Notification', COUNT(*) FROM [Notification]
UNION ALL SELECT N'ReceiveNotification', COUNT(*) FROM [ReceiveNotification]
UNION ALL SELECT N'Follow', COUNT(*) FROM [Follow]
UNION ALL SELECT N'SocialProfile', COUNT(*) FROM [SocialProfile]
UNION ALL SELECT N'AuditLog', COUNT(*) FROM [AuditLog]
UNION ALL SELECT N'DepartmentContact', COUNT(*) FROM [DepartmentContact];
GO

SELECT 
    c.CompanyName,
    c.Industry,
    c.CompanySize,
    STRING_AGG(cl.[Address], N' | ') AS Locations
FROM Company c
LEFT JOIN CompanyLocation cl ON c.CompanyID = cl.CompanyID
GROUP BY c.CompanyID, c.CompanyName, c.Industry, c.CompanySize;
GO

SELECT 
    CONCAT(js.FirstName, N' ', js.LastName) AS FullName,
    js.ExperienceLevel,
    js.CurrentLocation,
    STRING_AGG(CONCAT(s.SkillName, N' (', jss.ProficiencyLevel, N')'), N', ') AS Skills
FROM JobSeeker js
LEFT JOIN JobSeekerSkill jss ON js.JobSeekerID = jss.JobSeekerID
LEFT JOIN Skill s ON jss.SkillID = s.SkillID
GROUP BY js.JobSeekerID, js.FirstName, js.LastName, js.ExperienceLevel, js.CurrentLocation;
GO

SELECT 
    j.JobID,
    j.JobTitle,
    c.CompanyName,
    j.Location,
	CONCAT(FORMAT(j.SalaryMin, N'N0'), N' - ', FORMAT(j.SalaryMax, N'N0')) AS SalaryRange,
    j.JobStatus,
    STRING_AGG(
        CAST(CONCAT(s.SkillName, N' (', jrs.ProficiencyLevel, 
        CASE WHEN jrs.IsRequired = 1 THEN N' - Required' ELSE N' - Nice to have' END, N')') AS NVARCHAR(MAX)),
        N', '
    ) AS RequiredSkills
FROM Job j
INNER JOIN Company c ON j.CompanyID = c.CompanyID
LEFT JOIN JobRequireSkill jrs ON j.JobID = jrs.JobID
LEFT JOIN Skill s ON jrs.SkillID = s.SkillID
GROUP BY j.JobID, j.JobTitle, c.CompanyName, j.Location, j.SalaryMin, j.SalaryMax, j.JobStatus;
GO

SELECT 
    CONCAT(js.FirstName, N' ', js.LastName) AS Applicant,
    j.JobTitle,
    c.CompanyName,
    a.ApplicationDate,
    a.ApplicationStatus,
    a.InterviewDate
FROM Application a
INNER JOIN JobSeeker js ON a.JobSeekerID = js.JobSeekerID
INNER JOIN Job j ON a.JobID = j.JobID
INNER JOIN Company c ON j.CompanyID = c.CompanyID
ORDER BY a.ApplicationDate DESC;
GO

SELECT 
    c.CompanyName,
    CONCAT(js.FirstName, N' ', js.LastName) AS Reviewer,
    rc.ReviewTitle,
    rc.Rating,
    rc.ReviewDate,
    rc.VerificationStatus,
    CASE WHEN rc.IsAnonymous = 1 THEN N'Yes' ELSE N'No' END AS Anonymous
FROM ReviewCompany rc
INNER JOIN Company c ON rc.CompanyID = c.CompanyID
INNER JOIN JobSeeker js ON rc.JobSeekerID = js.JobSeekerID
ORDER BY rc.ReviewDate DESC;
GO

SELECT 
    s.SkillName,
    s.SkillCategory,
    s.PopularityScore,
    COUNT(DISTINCT jss.JobSeekerID) AS JobSeekersWithSkill,
    COUNT(DISTINCT CASE WHEN j.JobStatus = N'Open' THEN jrs.JobID END) AS OpenJobsRequiring
FROM Skill s
LEFT JOIN JobSeekerSkill jss ON s.SkillID = jss.SkillID
LEFT JOIN JobRequireSkill jrs ON s.SkillID = jrs.SkillID
LEFT JOIN Job j ON jrs.JobID = j.JobID
GROUP BY s.SkillID, s.SkillName, s.SkillCategory, s.PopularityScore
ORDER BY s.PopularityScore DESC, s.SkillName;
GO

SELECT 
    j.JobTitle,
    c.CompanyName,
    jm.ViewCount,
    jm.LikeCount,
    jm.AppliedCount,
    j.OpeningCount,
    CASE 
        WHEN jm.AppliedCount >= j.OpeningCount THEN N'High Demand'
        WHEN jm.AppliedCount >= j.OpeningCount * 0.5 THEN N'Medium Demand'
        ELSE N'Low Demand'
    END AS DemandLevel
FROM JobMetrics jm
INNER JOIN Job j ON jm.JobMetricID = j.JobID
INNER JOIN Company c ON j.CompanyID = c.CompanyID
ORDER BY jm.AppliedCount DESC;
GO

SELECT 
    CONCAT(js.FirstName, N' ', js.LastName) AS JobSeekerName,
    e.JobTitle,
    c.CompanyName,
    e.ExperienceType,
    e.StartDate,
    COALESCE(CAST(e.EndDate AS NVARCHAR(10)), N'Present') AS EndDate,
    CASE 
        WHEN e.EndDate IS NULL THEN DATEDIFF(MONTH, e.StartDate, GETDATE())
        ELSE DATEDIFF(MONTH, e.StartDate, e.EndDate)
    END AS DurationMonths
FROM Experience e
INNER JOIN JobSeeker js ON e.JobSeekerID = js.JobSeekerID
INNER JOIN Company c ON e.CompanyID = c.CompanyID
ORDER BY js.JobSeekerID, e.StartDate DESC;
GO

SELECT 
    CONCAT(js.FirstName, N' ', js.LastName) AS Follower,
    c.CompanyName AS Following,
    f.FollowDate
FROM Follow f
INNER JOIN JobSeeker js ON f.FollowerID = js.JobSeekerID
INNER JOIN Company c ON f.FolloweeID = c.CompanyID
ORDER BY f.FollowDate DESC;
GO

SELECT TOP 10
    al.Timestamp,
    COALESCE(CONCAT(js.FirstName, N' ', js.LastName), c.CompanyName, a.AdminName, N'System') AS Actor,
    al.ActionType,
    al.Detailed,
    al.IPAddress
FROM AuditLog al
LEFT JOIN JobSeeker js ON al.ActorID = js.JobSeekerID
LEFT JOIN Company c ON al.ActorID = c.CompanyID
LEFT JOIN Admin a ON al.ActorID = a.AdminId
ORDER BY al.Timestamp DESC;
GO

SELECT N'=== DATABASE SUMMARY STATISTICS ===' AS Info;
GO

SELECT 
    (SELECT COUNT(*) FROM [User]) AS TotalUsers,
    (SELECT COUNT(*) FROM [Company] WHERE VerificationStatus = N'ACCEPTED') AS VerifiedCompanies,
    (SELECT COUNT(*) FROM [JobSeeker]) AS TotalJobSeekers,
    (SELECT COUNT(*) FROM [Job] WHERE JobStatus = N'Open') AS OpenJobs,
    (SELECT COUNT(*) FROM [Application]) AS TotalApplications,
    (SELECT COUNT(*) FROM [Skill]) AS TotalSkills,
    (SELECT COUNT(*) FROM [ReviewCompany] WHERE VerificationStatus = N'Verified') AS VerifiedReviews;
GO

SELECT 
    EmploymentType,
    COUNT(*) AS JobCount,
    FORMAT(AVG(SalaryMin), N'N0') AS AvgMinSalary,
    FORMAT(AVG(SalaryMax), N'N0') AS AvgMaxSalary
FROM Job
WHERE JobStatus = N'Open'
GROUP BY EmploymentType;
GO

SELECT 
    ApplicationStatus,
    COUNT(*) AS Count,
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Application), 1), N'%') AS Percentage
FROM Application
GROUP BY ApplicationStatus
ORDER BY Count DESC;
GO

SELECT TOP 5
    s.SkillName,
    s.SkillCategory,
    s.PopularityScore,
    (SELECT COUNT(*) FROM JobRequireSkill jrs 
     INNER JOIN Job j ON jrs.JobID = j.JobID 
     WHERE jrs.SkillID = s.SkillID AND j.JobStatus = N'Open') AS JobDemand
FROM Skill s
ORDER BY PopularityScore DESC;
GO

SELECT 
    c.CompanyName,
    COUNT(j.JobID) AS TotalJobs,
    COUNT(CASE WHEN j.JobStatus = N'Open' THEN 1 END) AS OpenJobs,
    ISNULL(AVG(CAST(rc.Rating AS DECIMAL(3,2))), 0) AS AvgRating
FROM Company c
LEFT JOIN Job j ON c.CompanyID = c.CompanyID
LEFT JOIN ReviewCompany rc ON c.CompanyID = rc.CompanyID AND rc.VerificationStatus = N'Verified'
GROUP BY c.CompanyID, c.CompanyName
ORDER BY OpenJobs DESC;
GO

SELECT N'=== ALL DATA INSERTED SUCCESSFULLY ===' AS Status;
GO