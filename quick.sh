for i in t1r1 t1r2 t1r3 t2r1 t2r2 t2r3 t3r1 t3r2 t3r3
do 
    #bsub -N -o master_$i.o -e master_$i.e ruby master.rb -s human $i $i /project/itmatlab/aligner_benchmark -v 
    bsub -N -o master_$i.o -e master_$i.e ruby master.rb -s malaria $i $i /project/itmatlab/aligner_benchmark -v 
done