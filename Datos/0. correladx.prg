UPDATE HIS3 SET CORRELADX=1
USE HIS3 IN 1
SELECT IDCITA, DX, COUNT(*) AS REPETICIONES FROM HIS3 GROUP BY IDCITA, DX HAVING COUNT(*)>1 INTO CURSOR cdiag
SELECT cdiag
SCAN
	lccita=cdiag.idcita
	lcdx=cdiag.dx
	STORE 0 TO gnCount
	SELECT 1
	GO TOP
	LOCATE FOR idcita=lccita AND dx=lcdx
	DO WHILE FOUND( )
		gnCount = gnCount + 1
		REPLACE correladx WITH gnCount
		CONTINUE
	ENDDO
	SELECT cdiag
ENDSCAN