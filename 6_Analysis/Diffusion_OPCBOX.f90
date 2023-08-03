  Program msd_calculation

  implicit none

  integer :: i, j, k, n, ti, tf, tmax
  integer :: natom, nframe, ns
  integer(4) :: NTITLE, icntrl(20)
  real(8) :: dcd_cell(6)
  real(4) :: ri(3), rf(3), rif(3)
  character(100) :: argc
  character(80) :: dcdfile
  character(80) :: title(100)
  character(4)  :: HEADER

  real(4), allocatable :: rt(:,:), r(:,:,:) 
  real(8), allocatable :: msd(:,:), msd2(:,:) !, nsample(:)

  dcdfile = ""
  tmax = 0

  n = iargc()

  if ( ( n == 0 ) .or. (mod(n,2) /= 0 ) ) then
    write(6,*) "USAGE: diffusion -dcd [dcd file] (-tmax [max tau])"
    stop
  endif

  i = 0
  do 

    i = i + 1
    call getarg(i,argc)

    if ( argc == "-dcd" ) then
      call getarg(i+1,argc)
      dcdfile = argc
      i = i + 1
    endif

    if ( argc == "-tmax" ) then
      call getarg(i+1,argc)
      read(argc,*) tmax
      i = i + 1
    endif


    if ( i >= n ) exit

  enddo



  open(1,file=dcdfile,form='unformatted') ! ,access='stream')

  read(1) HEADER,icntrl(1:20)
  read(1) NTITLE,(title(i),i=1,NTITLE)
  read(1) natom
  nframe = icntrl(1)

  if ( tmax == 0 ) tmax = nframe/4
  allocate(rt(3,natom))
  allocate(r(3,nframe,natom/4))
  allocate(msd(4,tmax))
  allocate(msd2(4,tmax))
!  allocate(nsample(tmax))

  do k=1, nframe

    if ( icntrl(11) == 1 ) read(1) dcd_cell(1:6)
    read(1) rt(1,:)
    read(1) rt(2,:)
    read(1) rt(3,:)

    do i=1, natom/4
      r(1:3,k,i) = rt(1:3,4*(i-1)+1)
    enddo

  enddo

  deallocate(rt)

  close(1)

  natom = natom/4
  msd = 0.0d0 
!  nsample = 1.0d0

  do i=1, natom

    do ti=1, nframe-1

      ri(:) = r(:,ti,i)

      do tf=ti+1, min(ti+tmax,nframe)

        rf(:) = r(:,tf,i)
        rif = ri - rf

        msd(1:3,tf-ti) = rif(:)*rif(:) + msd(1:3,tf-ti)
        msd(4,tf-ti)   = dot_product(rif,rif) + msd(4,tf-ti)
        msd2(1:3,tf-ti) = rif(:)*rif(:)*rif(:)*rif(:) + msd2(1:3,tf-ti)
        msd2(4,tf-ti) = dot_product(rif,rif)*dot_product(rif,rif) + msd2(4,tf-ti)
!        nsample(tf-ti) = 1.0d0 + nsample(tf-ti)

      enddo

    enddo

  enddo

  do ti=1, tmax
!    if ( nsample(ti) /= 0.0d0 ) then
      msd(:,ti) = msd(:,ti)/(natom*(nframe-ti)) ! nsample(ti)
      msd2(:,ti) = msd2(:,ti)/(natom*(nframe-ti)) ! nsample(ti)
      msd2(:,ti) = sqrt(msd2(:,ti)-msd(:,ti)*msd(:,ti))
!    endif
  enddo


  !--- Output ---!

  open(10,file="msd.dat")
  write(10,"(a90)") "#      tau     msd_x sd(msd_x)&
                              &     msd_y sd(msd_y)&
                              &     msd_z sd(msd_z)&
                              &     msd   sd(msd)  "
  write(10,"(i10,8f10.3)") 0, (0.0, i=1, 8)
  do ti=1, tmax
    write(10,"(i10,8f10.3)") ti, (msd(i,ti), msd2(i,ti), i=1, 4)
  enddo
  close(10)

  end
