SET SERVEROUTPUT ON

BEGIN
    -- Tranzactie reusita
    transaction_pack.transaction_assigned_courses('silviu.butnaru@student.tuiasi.ro', 'Data Structures and Algorithms', 'Solution Architect');

    -- Tranzactie reusita
    transaction_pack.transaction_assigned_courses('silviu.butnaru@student.tuiasi.ro', 'Object Oriented', 'DevOps Engineer');
    
    -- Tranzactie reusita
    transaction_pack.transaction_assigned_courses('vlad.paraschiv@student.tuiasi.ro', 'Software Analysis and Design', 'Solution Architect');

    -- Tranzactie esuata, userul nu mai are certificate
    transaction_pack.transaction_assigned_courses('vlad.paraschiv@student.tuiasi.ro', 'Object Oriented', 'Solution Architect');

    -- Tranzactie reusita
    transaction_pack.transaction_assigned_courses('alberto-ionut.toscariu@student.tuiasi.ro', 'Tests and Maintenance', 'Cloud Partitioner');

    -- Tranzactie esuata, cantitate la cursul respectiv insuficienta
    transaction_pack.transaction_assigned_courses('silviu.butnaru@student.tuiasi.ro', 'Tests and Maintenance', 'Solution Architect');

    -- Tranzactie reusita
    transaction_pack.transaction_assigned_courses('alberto-ionut.toscariu@student.tuiasi.ro', 'Object Oriented', 'DevOps Engineer');

    -- Tranzactie esuata, userul nu mai are certificate
    transaction_pack.transaction_assigned_courses('alberto-ionut.toscariu@student.tuiasi.ro', 'Software Analysis and Design', 'DevOps Engineer');

    -- Tranzactie esuata, cantitate la cursul respectiv insuficienta
    transaction_pack.transaction_assigned_courses('silviu.butnaru@student.tuiasi.ro', 'Data Structures and Algorithms', 'Cloud Partitioner');
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('EMPLOYEES:');
    crud_employees_pack.read_all_employees();
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('CERTIFICATES:');
    crud_certificates_pack.read_all_certificates();
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('EMPLOYEE_CERTIFICATE:');
    crud_employee_certificate_pack.read_all_employee_certificate();
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('COURSES:');
    crud_courses_pack.read_all_courses();
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('ASSIGNED_COURSES:');
    transaction_pack.read_all_assigned_courses();
END;