#1. 데이터베이스 및 테이블 생성
#1.1 데이터베이스 생성
USE mysql;
DROP DATABASE IF EXISTS cookDB; -- 만약 cookDB가 존재하면 우선 삭제한다.
CREATE DATABASE cookDB;

#1.2 테이블 생성
USE cookDB;
CREATE TABLE userTbl -- 회원 테이블
( userID  	CHAR(8) NOT NULL PRIMARY KEY, -- 사용자 아이디(PK)
  userName    	VARCHAR(10) NOT NULL, -- 이름
  birthYear   INT NOT NULL,  -- 출생년도
  addr	  	CHAR(2) NOT NULL, -- 지역(경기,서울,경남 식으로 2글자만입력)
  mobile1	CHAR(3), -- 휴대폰의 국번(011, 016, 017, 018, 019, 010 등)
  mobile2	CHAR(8), -- 휴대폰의 나머지 전화번호(하이픈제외)
  height    	SMALLINT,  -- 키
  mDate    	DATE  -- 회원 가입일
);
CREATE TABLE buyTbl -- 회원 구매 테이블
(  num 		INT AUTO_INCREMENT NOT NULL PRIMARY KEY, -- 순번(PK)
   userID  	CHAR(8) NOT NULL, -- 아이디(FK)
   prodName 	CHAR(6) NOT NULL, --  물품명
   groupName 	CHAR(4)  , -- 분류
   price     	INT  NOT NULL, -- 단가
   amount    	SMALLINT  NOT NULL, -- 수량
   FOREIGN KEY (userID) REFERENCES userTbl(userID)
);
#2. 데이터 삽입
#2.1 사용자 데이터 삽입
INSERT INTO userTbl VALUES('YJS', '유재석', 1972, '서울', '010', '11111111', 178, '2008-8-8');
INSERT INTO userTbl VALUES('KHD', '강호동', 1970, '경북', '011', '22222222', 182, '2007-7-7');
INSERT INTO userTbl VALUES('KKJ', '김국진', 1965, '서울', '019', '33333333', 171, '2009-9-9');
INSERT INTO userTbl VALUES('KYM', '김용만', 1967, '서울', '010', '44444444', 177, '2015-5-5');
INSERT INTO userTbl VALUES('KJD', '김제동', 1974, '경남', NULL , NULL      , 173, '2013-3-3');
INSERT INTO userTbl VALUES('NHS', '남희석', 1971, '충남', '016', '66666666', 180, '2017-4-4');
INSERT INTO userTbl VALUES('SDY', '신동엽', 1971, '경기', NULL , NULL      , 176, '2008-10-10');
INSERT INTO userTbl VALUES('LHJ', '이휘재', 1972, '경기', '011', '88888888', 180, '2006-4-4');
INSERT INTO userTbl VALUES('LKK', '이경규', 1960, '경남', '018', '99999999', 170, '2004-12-12');
INSERT INTO userTbl VALUES('PSH', '박수홍', 1970, '서울', '010', '00000000', 183, '2012-5-5');
#2.2 구매 데이터 삽입
INSERT INTO buyTbl VALUES(NULL, 'KHD', '운동화', NULL   , 30,   2);
INSERT INTO buyTbl VALUES(NULL, 'KHD', '노트북', '전자', 1000, 1);
INSERT INTO buyTbl VALUES(NULL, 'KYM', '모니터', '전자', 200,  1);
INSERT INTO buyTbl VALUES(NULL, 'PSH', '모니터', '전자', 200,  5);
INSERT INTO buyTbl VALUES(NULL, 'KHD', '청바지', '의류', 50,   3);
INSERT INTO buyTbl VALUES(NULL, 'PSH', '메모리', '전자', 80,  10);
INSERT INTO buyTbl VALUES(NULL, 'KJD', '책'    , '서적', 15,   5);
INSERT INTO buyTbl VALUES(NULL, 'LHJ', '책'    , '서적', 15,   2);
INSERT INTO buyTbl VALUES(NULL, 'LHJ', '청바지', '의류', 50,   1);
INSERT INTO buyTbl VALUES(NULL, 'PSH', '운동화', NULL   , 30,   2);
INSERT INTO buyTbl VALUES(NULL, 'LHJ', '책'    , '서적', 15,   1);
INSERT INTO buyTbl VALUES(NULL, 'PSH', '운동화', NULL   , 30,   2);
#3. 데이터 조회
SELECT * FROM userTbl;
SELECT * FROM buyTbl;



#4. 스토어드 프로시저 생성 및 호출
#4-1한개의 입력 매개변수를 사용하는 프로시저:사용자 이름을 입력받아 해당 이름을 가진 사용자의 정보를 조회
USE cookDB;
DROP PROCEDURE IF EXISTS useProc1;
DELIMITER $$
CREATE PROCEDURE useProc1(IN uName VARCHAR(10))
BEGIN
SELECT * FROM userTBL WHERE userName = uName;
END $$
DELIMITER ;

CALL useProc1('이경규');

#4-2:두개의 입력 매개변수를 사용하는 프로시저:출생년도와 키를 입력받아, 입력한 출생년도보다 더 최근에 태어난 사람들 중에서 입력한 키보다 큰 사람들을 조회
DROP PROCEDURE IF EXISTS userProc2;
DELIMITER $$ 
CREATE PROCEDURE userProc2( 
IN userBirth INT, 
IN userHeight INT 
) 
BEGIN 
SELECT * FROM userTBL 
WHERE birthYear > userBirth AND height > userHeight;
END $$ 
DELIMITER ;
CALL userProc2(1970, 178);


#4-3조건문을 사용하는 프로시저:사용자 이름을 입력받아 해당 사용자의 출생년도에 따라 "아직 젊군요.." 또는 "나이가 지긋하네요.."라는 메시지를 반환
DROP PROCEDURE IF EXISTS ifelseProc;
DELIMITER $$ 
CREATE PROCEDURE ifelseProc( 
 IN uName VARCHAR(10) 
) 
BEGIN 
	DECLARE bYear INT; -- 변수 선언 
	SELECT birthYear into bYear FROM userTBL WHERE userName = uName;
	IF (bYear >= 1970) THEN 
		SELECT '아직 젊군요..';
	ELSE 
		SELECT '나이가 지긋하네요..';
	END IF;
END $$ 
DELIMITER ;

CALL ifelseProc ('김국진');

#4-4CASE 문을 사용하는 프로시저:사용자 이름을 입력받아 해당 사용자의 출생년도에 따라 띠(원숭이, 닭 등)를 계산하여 출력
DROP PROCEDURE IF EXISTS caseProc;
DELIMITER $$ 
CREATE PROCEDURE caseProc( 
IN uName VARCHAR(10) 
) 
BEGIN 
 DECLARE bYear INT;
 DECLARE tti CHAR(3); -- 띠를 저장할 변수 
  SELECT birthYear INTO bYear FROM userTBL 
   WHERE userName = uName;
  CASE 
	WHEN (bYear%12 = 0) THEN SET tti = '원숭이';
	WHEN (bYear%12 = 1) THEN SET tti = '닭';
	WHEN (bYear%12 = 2) THEN SET tti = '개';
	WHEN (bYear%12 = 3) THEN SET tti = '돼지';
	WHEN (bYear%12 = 4) THEN SET tti = '쥐';
	WHEN (bYear%12 = 5) THEN SET tti = '소';
	WHEN (bYear%12 = 6) THEN SET tti = '호랑이';
	WHEN (bYear%12 = 7) THEN SET tti = '토끼';
	WHEN (bYear%12 = 8) THEN SET tti = '용';
	WHEN (bYear%12 = 9) THEN SET tti = '뱀';
	WHEN (bYear%12 = 10) THEN SET tti = '말';
	ELSE SET tti = '양';
 END CASE;
 SELECT CONCAT(uName, '의 띠 ==>', tti);
END $$ 
DELIMITER ;

CALL caseProc ('박수홍');

#4-5커서를 사용하는 프로시저:커서를 사용하여 모든 사용자의 키를 조회하고, 평균 키를 계산하여 출력
DROP PROCEDURE IF EXISTS cursorProc;
DELIMITER $$
CREATE PROCEDURE cursorProc() 
BEGIN 
	DECLARE userHeight INT;  
	DECLARE usercnt INT DEFAULT 0; 
	DECLARE totalHeight INT DEFAULT 0; 
 
	DECLARE endOfRow BOOLEAN DEFAULT FALSE; 

	DECLARE userCursor CURSOR FOR 
		SELECT height FROM userTBL;

	DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET endOfRow = TRUE;
 
	OPEN userCursor; 

	cursor_loop: LOOP 
		FETCH userCursor INTO userHeight; 

		IF endOfRow THEN
			LEAVE cursor_loop;
		END IF;

		SET usercnt = usercnt + 1;
		SET totalHeight = totalHeight + userHeight;
	END LOOP cursor_loop;


	SELECT CONCAT('고객 키의 평균 ==> ', (totalHeight/usercnt));

	CLOSE userCursor; 
END $$ 
DELIMITER ;

CALL cursorProc();

#6. 테이블 구조 변경 및 고객 등급 업데이트 프로시저:모든 사용자의 구매 정보를 바탕으로 고객 등급(최우수고객, 우수고객 등)을 업데이트
USE cookDB;
ALTER TABLE userTBL ADD grade VARCHAR(5);#ALTER TABLE: 기존 테이블의 구조를 수정

DROP PROCEDURE IF EXISTS gradeProc;
DELIMITER $$ 
CREATE PROCEDURE gradeProc() 
BEGIN 
     DECLARE id VARCHAR(10); 
     DECLARE hap BIGINT; 
     DECLARE userGrade CHAR(5); 
 
     DECLARE endOfRow BOOLEAN DEFAULT FALSE;
 
   DECLARE userCuror CURSOR FOR 
        SELECT U.userid, sum(price * amount) 
            FROM buyTBL B 
               RIGHT OUTER JOIN userTBL U 
               ON B.userid = U.userid 
            GROUP BY U.userid, U.userName;
 
   DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET endOfRow = TRUE;

    OPEN userCuror; 
    grade_loop: LOOP 
        FETCH userCuror INTO id, hap;
        IF endOfRow THEN
            LEAVE grade_loop;
            
	END IF;
 
	CASE 
            WHEN (hap >= 1500) THEN SET userGrade = '최우수고객';
            WHEN (hap >= 1000) THEN SET userGrade ='우수고객';
            WHEN (hap >= 1) THEN SET userGrade ='일반고객';
            ELSE SET userGrade ='유령고객';
        END CASE;
 
        UPDATE userTBL SET grade = userGrade WHERE userID = id;
     END LOOP grade_loop;
 
     CLOSE userCuror; 
 END $$ 
 
DELIMITER ;

CALL gradeProc();
SELECT * FROM userTBL;
 









