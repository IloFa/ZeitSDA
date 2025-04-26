----- getestet auf https://sqliteonline.com
/* CREATE TABLE kunde(
    artikel_id INT
    ,kunde_id INT
    ,bestelldatum DATE
);

INSERT INTO kunde (artikel_id, kunde_id, bestelldatum) VALUES
(37309, 1227456, '2017-01-16'),
(37309, 1227456, '2017-02-16'),
(37602, 1534203, '2016-12-09'),
(37050, 60195, '2017-12-19'),
(31412, 1286879, '2013-03-22'),
(30772, 567159, '2013-02-06'),
(40033, 828175, '2017-12-08'),
(37050, 727289, '2016-09-26'),
(33427, 540551, '2014-09-12'),
(39500, 827448, '2017-11-30'),
(37602, 536996, '2016-11-07'),
(33427, 732947, '2016-07-19'),
(27209, 473040, '2013-11-29'),
(28404, 635172, '2015-12-14'),
(30772, 1578206, '2013-04-06'),
(37050, 129608 , '2016-09-29'),
(37309, 1141454, '2017-03-13'),
(39431, 1734740, '2017-08-20'),
(34818, 579888, '2014-10-28'),
(33993, 581531, '2014-09-02'),
(30772, 545842, '2013-08-26'),
(33427, 634077, '2014-12-05'),
(33427, 617654, '2014-10-28'); */

With base as (
    Select
    kunde_id
    from kunde
    group by kunde_id
    having count (*) >1) /* Eingrenzen der Grundmenge. Nur Kunden die mehrmals in der Liste auftauchen, sei es über merhere Artiel oder mehrere Kaufdaten. */
    , kauf as (
        Select
        kd.kunde_id
        , kd.bestelldatum
        , ROW_NUMBER() over (PARTITION BY kd.kunde_id order by kd.bestelldatum) as anz_kauf /* Reihenfolge der Käufe feststellen*/
        , (kd.bestelldatum-LAG(kd.bestelldatum)OVER(PARTITION BY kd.kunde_id ORDER_BY kd.bestelldatum))::INT as prev_best /* Berechnet die Tage zwischen zweiter und
        erster Bestellung. Logik notwendig, damit man in der Zeile 2 des Kaufs den Abstand zwischen den Käufen auslesen kann */
        --, DATEDIFF(day, LAG(kd.bestelldatum)OVER (PARTITION BY kd.kunde_id order by KD.bestelldatum), bestelldatum) /* je nach Datenbank DATEDIFF möglich*/
        from kunde kd
        join base b on
        kd.kunde_id = b.kunde_id /* inner join auf Kunden aus Grundmenge*/
    )
    Select
    kunde_id
    , prev_best as tage_bis_2_best
    from kauf
    where anz_kauf = 2 /* durch die LAG Logik, kann man in Zeile 2 der Daten je Kunde auslesen, wie viele Tage zwischen Kauf 1 und 2 liegen*/
    ; 