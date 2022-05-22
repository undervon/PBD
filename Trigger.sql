SET SERVEROUTPUT ON

CREATE OR REPLACE TRIGGER check_quantity
BEFORE INSERT OR UPDATE ON courses
FOR EACH ROW
BEGIN
    IF :new.quantity < 0 THEN
        DBMS_OUTPUT.PUT_LINE('Insert sau update esuat! Cantitate 0');
        RAISE transaction_pack.e_invalid_quantity;
    END IF;
END check_quantity;