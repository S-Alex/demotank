# demotank
Программа для танка из видео.
https://youtu.be/T8oXPLpGYnM

Открытая международная олимпиада по прикладному программированию на базе стендов EV8031/AVR.
Конкурсное задание по робототехнике "Танк-робот монетоискатель".
Проводилась компанией OpenSystem совместно с КПИ (Национальный технический университет Украины «Киевский политехнический институт»). Киев, КПИ, апрель 2011г. 

Конкурсное задание «Робот Монетоискатель» 
 
Условия трассы. 
 
1. Два одинаковых горизонтальных поля 90*360 см. 
2. Препятствий, а также «мешков»  в виде ограничительной линии- нет. 
3. По краям поля две параллельные ограничительные линии (1см),  расстояние от края 
стола 5 -10 см. 
4. Линия старта. 
4.1. Старт – танк находится двумя задними датчиками бамперов, на линии старта. 
Фактический старт танка должен начаться после включения мигающего с частотой  
80 +/-10 герц светодиода, который находится за финишной линией (в центре).  
4.2 Стартуют одновременно два танка в разных полях. 
5. Линия финиша. 
5.1. В конце трассы по все ширине стола расположено препятствие высотой 10-15 см, на 
котором находится светодиод задающий финишное направление. 
5.2. – Танк должен заехать на финишную ограничительную линию двумя передними 
датчиками бампера.  
5.3 Расстояние от вертикального препятствия до финишной ограничительной линии 15 см. 
 
Задача робота 
1. На поле, ограниченной линиями найти 5 монет номиналом 1 (одна) гривна. 
2. Монет по 1 гривны на поле >> чем 5, а 25 копеек >> чем гривней. 
3. Танк, нашедший монету должен на нее заехать- покрыть телом (корпусом) полностью 
монету, что бы ее не было видно при виде сверху, подать звуковую сигнализацию. На 
найденной монете развернуться на 360 градусов. 
 
Приоритетность критериев определения победителя. 
 
1.  Нахождение танком от 5 до 1 монеты по одной гривны. Подтверждение 
нахождения звуковая сигнализация и разворот танка на монете на 360 градусов. 
2.  Прохождение на минимальное время трассы. 
3.  Количество штрафных баллов. Штрафные баллы начисляются за наезд гусеницей 
на вторую ограничительную линию, не покрытие полностью танком монеты при 
развороте на 360 грд. 
4.  Проезд передними датчиками за финишную линию. 
 
 
Перед стартом будет дано контрольное время заезда. (максимальное время прохождения) 
