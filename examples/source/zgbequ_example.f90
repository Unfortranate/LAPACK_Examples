    Program zgbequ_example

!     ZGBEQU Example Program Text

!     Copyright (c) 2018, Numerical Algorithms Group (NAG Ltd.)
!     For licence see
!       https://github.com/numericalalgorithmsgroup/LAPACK_Examples/blob/master/LICENCE.md

!     .. Use Statements ..
      Use blas_interfaces, Only: zdscal
      Use lapack_example_aux, Only: nagf_blas_zddscl, &
        nagf_file_print_matrix_complex_band
      Use lapack_interfaces, Only: zgbequ
      Use lapack_precision, Only: dp
!     .. Implicit None Statement ..
      Implicit None
!     .. Parameters ..
      Real (Kind=dp), Parameter :: one = 1.0_dp
      Real (Kind=dp), Parameter :: thresh = 0.1_dp
      Integer, Parameter :: nin = 5, nout = 6
!     .. Local Scalars ..
      Real (Kind=dp) :: amax, big, colcnd, rowcnd, small
      Integer :: i, i0, i1, ifail, ilen, info, j, k, kl, ku, ldab, n
!     .. Local Arrays ..
      Complex (Kind=dp), Allocatable :: ab(:, :)
      Real (Kind=dp), Allocatable :: c(:), r(:)
!     .. Intrinsic Procedures ..
      Intrinsic :: epsilon, max, min, radix, real, tiny
!     .. Executable Statements ..
      Write (nout, *) 'ZGBEQU Example Program Results'
      Write (nout, *)
      Flush (nout)
!     Skip heading in data file
      Read (nin, *)
      Read (nin, *) n, kl, ku
      ldab = kl + ku + 1
      Allocate (ab(ldab,n), c(n), r(n))

!     Read the band matrix A from data file

      k = ku + 1
      Read (nin, *)((ab(k+i-j,j),j=max(i-kl,1),min(i+ku,n)), i=1, n)

!     Print the matrix A

!     ifail: behaviour on error exit
!             =0 for hard exit, =1 for quiet-soft, =-1 for noisy-soft
      ifail = 0
      Call nagf_file_print_matrix_complex_band(n, n, kl, ku, ab, ldab, &
        'Matrix A', ifail)

      Write (nout, *)

!     Compute row and column scaling factors

      Call zgbequ(n, n, kl, ku, ab, ldab, r, c, rowcnd, colcnd, amax, info)

      If (info>0) Then
        If (info<=n) Then
          Write (nout, 100) 'Row ', info, ' of A is exactly zero'
        Else
          Write (nout, 100) 'Column ', info - n, ' of A is exactly zero'
        End If
      Else

!       Print ROWCND, COLCND, AMAX and the scale factors

        Write (nout, 110) 'ROWCND =', rowcnd, ', COLCND =', colcnd, &
          ', AMAX =', amax
        Write (nout, *)
        Write (nout, *) 'Row scale factors'
        Write (nout, 120) r(1:n)
        Write (nout, *)
        Write (nout, *) 'Column scale factors'
        Write (nout, 120) c(1:n)
        Write (nout, *)
        Flush (nout)

!       Compute values close to underflow and overflow

        small = tiny(1.0E0_dp)/(epsilon(1.0E0_dp)*real(radix(1.0E0_dp),kind=dp &
          ))
        big = one/small
        If ((rowcnd>=thresh) .And. (amax>=small) .And. (amax<=big)) Then
          If (colcnd<thresh) Then

!           Just column scale A
            Do j = 1, n
              i1 = 1 + max(1, j-ku) - (j-ku)
              ilen = min(n, j+kl) - max(1, j-ku) + 1
              Call zdscal(ilen, c(j), ab(i1,j), 1)
            End Do

          End If
        Else If (colcnd>=thresh) Then

!         Just row scale A
          Do j = 1, n
            i0 = max(1, j-ku)
            i1 = 1 + i0 - (j-ku)
            ilen = min(n, j+kl) - i0 + 1
            Call nagf_blas_zddscl(ilen, r(i0), 1, ab(i1,j), 1)
          End Do

        Else

!         Row and column scale A
          Do j = 1, n
            i0 = max(1, j-ku)
            i1 = 1 + i0 - (j-ku)
            ilen = min(n, j+kl) - i0 + 1
            Call zdscal(ilen, c(j), ab(i1,j), 1)
            Call nagf_blas_zddscl(ilen, r(i0), 1, ab(i1,j), 1)
          End Do

        End If

!       Print the scaled matrix
        ifail = 0
        Call nagf_file_print_matrix_complex_band(n, n, kl, ku, ab, ldab, &
          'Scaled matrix', ifail)

      End If

100   Format (1X, A, I4, A)
110   Format (1X, 3(A,1P,E8.1))
120   Format ((1X,1P,7E11.2))
    End Program
