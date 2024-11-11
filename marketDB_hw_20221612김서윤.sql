DROP DATABASE IF EXISTS market_db;
CREATE DATABASE market_db;

USE market_db;
CREATE TABLE member -- 회원 테이블
( mem_id  		CHAR(8) NOT NULL PRIMARY KEY, -- 사용자 아이디(PK)
  mem_name    	VARCHAR(10) NOT NULL, -- 이름
  mem_number    INT NOT NULL,  -- 인원수
  addr	  		CHAR(2) NOT NULL, -- 지역(경기,서울,경남 식으로 2글자만입력)
  phone1		CHAR(3), -- 연락처의 국번(02, 031, 055 등)
  phone2		CHAR(8), -- 연락처의 나머지 전화번호(하이픈제외)
  height    	SMALLINT,  -- 평균 키
  debut_date	DATE  -- 데뷔 일자
);
CREATE TABLE buy -- 구매 테이블
(  num 		INT AUTO_INCREMENT NOT NULL PRIMARY KEY, -- 순번(PK)
   mem_id  	CHAR(8) NOT NULL, -- 아이디(FK)
   prod_name 	CHAR(6) NOT NULL, --  제품이름
   group_name 	CHAR(4)  , -- 분류
   price     	INT  NOT NULL, -- 가격
   amount    	SMALLINT  NOT NULL, -- 수량
   FOREIGN KEY (mem_id) REFERENCES member(mem_id)
);

INSERT INTO member VALUES('TWC', '트와이스', 9, '서울', '02', '11111111', 167, '2015.10.19');
INSERT INTO member VALUES('BLK', '블랙핑크', 4, '경남', '055', '22222222', 163, '2016.08.08');
INSERT INTO member VALUES('WMN', '여자친구', 6, '경기', '031', '33333333', 166, '2015.01.15');
INSERT INTO member VALUES('OMY', '오마이걸', 7, '서울', NULL, NULL, 160, '2015.04.21');
INSERT INTO member VALUES('GRL', '소녀시대', 8, '서울', '02', '44444444', 168, '2007.08.02');
INSERT INTO member VALUES('ITZ', '잇지', 5, '경남', NULL, NULL, 167, '2019.02.12');
INSERT INTO member VALUES('RED', '레드벨벳', 4, '경북', '054', '55555555', 161, '2014.08.01');
INSERT INTO member VALUES('APN', '에이핑크', 6, '경기', '031', '77777777', 164, '2011.02.10');
INSERT INTO member VALUES('SPC', '우주소녀', 13, '서울', '02', '88888888', 162, '2016.02.25');
INSERT INTO member VALUES('MMU', '마마무', 4, '전남', '061', '99999999', 165, '2014.06.19');

INSERT INTO buy VALUES(NULL, 'BLK', '지갑', NULL, 30, 2);
INSERT INTO buy VALUES(NULL, 'BLK', '맥북프로', '디지털', 1000, 1);
INSERT INTO buy VALUES(NULL, 'APN', '아이폰', '디지털', 200, 1);
INSERT INTO buy VALUES(NULL, 'MMU', '아이폰', '디지털', 200, 5);
INSERT INTO buy VALUES(NULL, 'BLK', '청바지', '패션', 50, 3);
INSERT INTO buy VALUES(NULL, 'MMU', '에어팟', '디지털', 80, 10);
INSERT INTO buy VALUES(NULL, 'GRL', '혼공SQL', '서적', 15, 5);
INSERT INTO buy VALUES(NULL, 'APN', '혼공SQL', '서적', 15, 2);
INSERT INTO buy VALUES(NULL, 'APN', '청바지', '패션', 50, 1);
INSERT INTO buy VALUES(NULL, 'MMU', '지갑', NULL, 30, 1);
INSERT INTO buy VALUES(NULL, 'APN', '혼공SQL', '서적', 15, 1);
INSERT INTO buy VALUES(NULL, 'MMU', '지갑', NULL, 30, 4);

SELECT * FROM member;
SELECT * FROM buy;

#<1>저장 프로시저 만들기
 -- 1번 user_proc1(‘에이핑크’):그룹명을 입력으로 받아 그룹 이름, 멤버수와 데뷔 날짜 출력
use market_db;
DROP procedure if exists user_proc1;
delimiter $$
create procedure user_proc1(in username VARCHAR(10))
begin
	select mem_name, mem_number, debut_date from member where mem_name = username;
end $$
delimiter ;

call user_proc1('에이핑크');

 -- 2번 user_proc2(6, 165)
 -- : 입력받은 숫자보다 멤버수가 많고, 입력받은 키보다 멤버 평균키가 큰 그룹의 모든 정보 출력
DROP procedure if exists user_proc2;
delimiter $$
create procedure user_proc2(in usernumber INT,in userheight SMALLINT)
begin
	select *  from member where mem_number> usernumber and height > userheight ;
end $$
delimiter ;

call user_proc2(6, 165);

 -- 3번 message_proc(‘오마이걸’) 
 -- : 입력받은 그룹이 데뷔년도가 2015년 이후이면 ‘신인가수네요. 화이팅하세요＇출력, 
 -- 2015년 이전이면 ‘고참가수네요. 그동안 수고하셨어요‘ 출력
DROP PROCEDURE IF EXISTS message_proc;
DELIMITER $$
CREATE PROCEDURE message_proc(IN memname varchar(10))
BEGIN
	declare debutyear int;
    select year(debut_date) into debutyear from member 
		where mem_name = memname;
	if (debutyear >= 2015) then
		select '신인가수네요. 화이팅하세요';
	else
		select '고참가수네요. 그동안 수고하셨어요';
	end if;
		
END $$
delimiter ;
call message_proc('오마이걸');

-- 4번 avg_member(  ) : 멤버들의 평균 수 출력
DROP procedure if exists avg_member;
delimiter $$
create procedure avg_member()
BEGIN
	DECLARE membernumber FLOAT;-- 멤버 수
    DECLARE membercount INT DEFAULT 0;-- 멤버 수를 저장할 변수(읽을 행의 수 카운트)
    DECLARE totalmember INT DEFAULT 0; -- 총 멤버 수
     
	DECLARE endOfRow BOOLEAN DEFAULT FALSE; 
	-- 커서 선언
	DECLARE member_Cursor CURSOR FOR 
		SELECT mem_number FROM member;
	-- 반복조건선언(더 이상 읽을 행이 없을 때 실행할 내용 설정)
	DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET endOfRow = TRUE;
	-- 커서 열기
	OPEN member_Cursor; 
	-- 커서 반복문,커서에서 데이터 가져오고 데이터 처리
	cursor_loop: LOOP 
		FETCH member_Cursor INTO membernumber; 

		IF endOfRow THEN
			LEAVE cursor_loop;
		END IF;

		SET membercount = membercount + 1;
		SET totalmember = totalmember + membernumber;
	END LOOP cursor_loop;


	SELECT CONCAT('멤버 수의 평균 ==> ', (totalmember/membercount));
	-- 커서 닫기
	CLOSE member_Cursor; 
END $$
DELIMITER ;

CALL avg_member();


#<2>트리거 만들기
-- singer테이블 생성
DROP TABLE IF EXISTS singer;
CREATE TABLE singer (SELECT mem_id, mem_name, mem_number, addr FROM member);
-- backup_singer테이블 생성
DROP TABLE IF EXISTS backup_singer;
CREATE TABLE backup_singer
( mem_id   CHAR(8) NOT NULL ,   
  mem_name VARCHAR(10) NOT NULL,  
  mem_number INT NOT NULL,   
  addr	   CHAR(2) NOT NULL,  
  modType  CHAR(2), -- 변경된 타입. '수정' 또는 '삭제' 
  modDate  DATE, -- 변경된 날짜  
  modUser  VARCHAR(30) -- 변경한 사용자
  );

-- 1)Update 트리거 
DROP TRIGGER IF EXISTS singer_update_Trg;
DELIMITER $$
CREATE TRIGGER singer_update_Trg 
	AFTER UPDATE 
    ON singer
    FOR each row
BEGIN
	INSERT INTO backup_singer VALUES( OLD.mem_id, OLD.mem_name, OLD.mem_number,
		OLD.addr, '수정', curdate(), current_user() );
END $$
DELIMITER ; 
-- 2) delete  트리거 
DROP TRIGGER IF EXISTS singer_delete_Trg;
DELIMITER $$
CREATE TRIGGER singer_delete_Trg 
	AFTER delete 
    ON singer
    FOR each row
BEGIN
	INSERT INTO backup_singer VALUES( OLD.mem_id, OLD.mem_name, OLD.mem_number,
		OLD.addr, '삭제', curdate(), current_user() );
END $$
DELIMITER ; 

-- Update실행 후 backup_singer테이블 확인
SET SQL_SAFE_UPDATES = 0;  -- 안전 모드 해제
Update singer set addr = '영국' where mem_id = 'BLK';
SET SQL_SAFE_UPDATES = 1;  -- 안전 모드 다시 활성화

Select * from backup_singer; 


-- Delete실행 후 backup_singer테이블 확인
SET SQL_SAFE_UPDATES = 0; 
Delete from singer where mem_number >= 7;
SET SQL_SAFE_UPDATES = 1;

Select * from backup_singer;


#<3>저장 함수 만들기->데뷔 연도를 입력하면 활동 햇수를 출력하는 함수
SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS calcYearFunc;
DELIMITER $$
CREATE FUNCTION calcYearFunc(debutyear INT)
	RETURNS INT
BEGIN
	RETURN YEAR(CURDATE()) - debutyear ;
END $$

DELIMITER ;

SELECT calcYearFunc(2010) AS '활동햇수' 




