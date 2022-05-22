SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE crud_courses_pack AS
    PROCEDURE create_course (v_name IN courses.name%TYPE, 
    v_duration IN courses.duration%TYPE, 
    v_quantity IN courses.quantity%TYPE);
    
    PROCEDURE read_first_specified_courses (v_no_courses IN NUMBER);
    
    PROCEDURE read_all_courses;
    
    PROCEDURE read_course_by_id (v_id IN courses.id%TYPE);
    
    FUNCTION read_course_by_name (v_name courses.name%TYPE) RETURN courses.id%TYPE;
    
	FUNCTION read_course_quantity_by_id(v_id courses.id%TYPE) RETURN courses.quantity%TYPE;
	
    PROCEDURE update_course_by_id (v_id IN courses.id%TYPE,
    v_name courses.name%TYPE,
    v_duration courses.duration%TYPE,
    v_quantity courses.quantity%TYPE);
	
	PROCEDURE update_couse_quantity_by_id(v_id IN courses.id%TYPE,
	v_quantity courses.quantity%TYPE);
    
    PROCEDURE delete_course_by_id (v_id IN courses.id%TYPE);
    
    PROCEDURE delete_all_courses;
END crud_courses_pack;
/

CREATE OR REPLACE PACKAGE BODY crud_courses_pack AS
    -- 1. CREATE COURSES
    PROCEDURE create_course (
        v_name IN courses.name%TYPE, 
        v_duration IN courses.duration%TYPE, 
        v_quantity IN courses.quantity%TYPE
    ) 
    IS
    BEGIN
      INSERT INTO courses(name, duration, quantity) VALUES (v_name, v_duration, v_quantity);
    END create_course;

    -- 2. READ COURSES
    PROCEDURE read_first_specified_courses (v_no_courses IN NUMBER) 
    IS
        v_courses_record courses%ROWTYPE;
        CURSOR c IS SELECT * FROM courses ORDER BY id ASC;
    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO v_courses_record.id, v_courses_record.name, v_courses_record.duration, v_courses_record.quantity;
            EXIT WHEN c%ROWCOUNT > v_no_courses OR c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_courses_record.id || ' | NAME: ' || v_courses_record.name
            || ' | DURATION: ' || v_courses_record.duration 
            || ' | QUANTITY: ' || v_courses_record.quantity);
        END LOOP;
        CLOSE c;
    END read_first_specified_courses;

    PROCEDURE read_all_courses
    IS
        v_courses_record courses%ROWTYPE;
        CURSOR c IS SELECT * FROM courses ORDER BY id ASC;
    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO v_courses_record.id, v_courses_record.name, v_courses_record.duration, v_courses_record.quantity;
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_courses_record.id || ' | NAME: ' || v_courses_record.name
            || ' | DURATION: ' || v_courses_record.duration 
            || ' | QUANTITY: ' || v_courses_record.quantity);
        END LOOP;
        CLOSE c;
    END read_all_courses;

    PROCEDURE read_course_by_id (v_id IN courses.id%TYPE)
    IS
        v_name courses.name%TYPE;
        v_duration courses.duration%TYPE;
        v_quantity courses.quantity%TYPE;
    BEGIN
        SELECT name, duration, quantity INTO v_name, v_duration, v_quantity FROM courses WHERE id = v_id;
            DBMS_OUTPUT.PUT_LINE('NAME: ' || v_name
            || ' | DURATION: ' || v_duration 
            || ' | QUANTITY: ' || v_quantity);
--            
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Cursul cu id-ul: ' || v_id || ' nu exista in DB');
    END read_course_by_id;

    FUNCTION read_course_by_name (v_name courses.name%TYPE) RETURN courses.id%TYPE
    IS
        v_id courses.id%TYPE;
    BEGIN
        SELECT id INTO v_id FROM courses WHERE name = v_name;
        RETURN (v_id);
    END read_course_by_name;

	FUNCTION read_course_quantity_by_id(v_id courses.id%TYPE) RETURN courses.quantity%TYPE
	IS
		v_quantity courses.quantity%TYPE;
	BEGIN
		SELECT quantity INTO v_quantity FROM courses WHERE id = v_id;
		RETURN (v_quantity);
	END read_course_quantity_by_id;

    -- 3. UPDATE COURSES
    PROCEDURE update_course_by_id (
        v_id IN courses.id%TYPE,
        v_name courses.name%TYPE,
        v_duration courses.duration%TYPE,
        v_quantity courses.quantity%TYPE
        )
    IS
    BEGIN
        UPDATE courses SET name = v_name, duration = v_duration, quantity = v_quantity WHERE id = v_id;
    END update_course_by_id;

	PROCEDURE update_couse_quantity_by_id(
		v_id IN courses.id%TYPE,
		v_quantity courses.quantity%TYPE
		)
	IS
	BEGIN
		UPDATE courses SET quantity = v_quantity WHERE id = v_id;
	END update_couse_quantity_by_id;

    -- 4. DELETE COURSES
    PROCEDURE delete_course_by_id (v_id IN courses.id%TYPE)
    IS
    BEGIN
        DELETE FROM courses WHERE id = v_id;
    END delete_course_by_id;

    PROCEDURE delete_all_courses
    IS
    BEGIN
        DELETE FROM courses;
    END delete_all_courses;
END crud_courses_pack;