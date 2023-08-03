  Program dielectric

  implicit none

  integer :: i, j, k, n, id
  integer :: natom, nframe, ns
  integer(4) :: NTITLE, icntrl(20)
  real(8) :: dcd_cell(6), box(3)
  real(4) :: ri(3), rj(3), rij(3)
  real(4) :: q(1:4), temp, vol, volt
  character(100) :: argc
  character(80) :: dcdfile
  character(80) :: title(100)
  character(4)  :: HEADER

  real(4), allocatable :: r(:,:) 
  real(8) :: M(3), M2(3), rq(3), Mt(3), M2t(3), eps(3)

  real(4), parameter :: EA_IN_DEBYE = 4.80320
  real(4), parameter :: FAC = 30339.2873923741  ! Prefactor for calculating dielectric constant

  dcdfile = ""
  temp = 298.0

  n = iargc()

  if ( ( n == 0 ) .or. (mod(n,2) /= 0 ) ) then
    write(6,*) "USAGE: dielectric -dcd [dcd file] -temp [temperature]"
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

    if ( argc == "-temp" ) then
      call getarg(i+1,argc)
      read(argc,*) temp
      i = i + 1
    endif

    if ( i >= n ) exit

  enddo


  open(1,file=dcdfile,form='unformatted') ! ,access='stream')

  read(1) HEADER,icntrl(1:20)
  read(1) NTITLE,(title(i),i=1,NTITLE)
  read(1) natom
  allocate(r(3,natom))

  nframe = icntrl(1)

  !--- OPC water ---!
  q(1) =  0.000
  q(2) =  0.679142
  q(3) =  0.679142
  q(4) = -1.358284

  q = q*EA_IN_DEBYE

  M  = 0.0d0
  M2 = 0.0d0
  vol = 0.0

  do k=1, nframe

    if ( icntrl(11) == 1 ) read(1) dcd_cell(1:6)
    box(1) = dcd_cell(1)
    box(2) = dcd_cell(3)
    box(3) = dcd_cell(6)
    read(1) r(1,:)
    read(1) r(2,:)
    read(1) r(3,:)

    vol = box(1)*box(2)*box(3) + vol

    rq = 0.0d0

    do i=1, natom, 4

      rq(1:3) = r(1:3,i  )*q(1) + rq(1:3)
      rq(1:3) = r(1:3,i+1)*q(2) + rq(1:3)
      rq(1:3) = r(1:3,i+2)*q(3) + rq(1:3)
      rq(1:3) = r(1:3,i+3)*q(4) + rq(1:3)

    enddo

    M = rq + M
    M2 = rq*rq + M2

    Mt = M/k
    M2t = M2/k
    volt = vol/k

    eps = M2t - Mt**2
    eps = eps*FAC/temp/volt 
    eps = 3.0d0*eps + 1.0d0

  enddo

  write(6,"(f12.3)") sum(eps(:))/3.0d0 

  close(1)

  end
