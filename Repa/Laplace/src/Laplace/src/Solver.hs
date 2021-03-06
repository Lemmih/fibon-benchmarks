{-# LANGUAGE BangPatterns, PackageImports #-}
module Solver 
	(solveLaplace)
where	
import Data.Array.Repa		as A
import qualified Data.Array.Repa.Shape	as S
import "dph-prim-par" Data.Array.Parallel.Unlifted				(Elt)
import qualified "dph-prim-par" Data.Array.Parallel.Unlifted			as U


-- | Solver for the Laplace equation.
solveLaplace
	:: Int			-- ^ Number of iterations to use.
	-> Array DIM2 Double	-- ^ Boundary value mask.
	-> Array DIM2 Double	-- ^ Boundary values.
	-> Array DIM2 Double	-- ^ Initial state.
	-> Array DIM2 Double

{-# NOINLINE solveLaplace #-}
solveLaplace steps arrBoundMask@Manifest{} arrBoundValue@Manifest{} arrInit@Manifest{}
 = go steps arrInit
 where	go i arr@Manifest{}
	   | i == 0	= arr
	   | otherwise	= go (i - 1) 
			$ force
			$ applyBoundary arrBoundMask arrBoundValue
			$ relaxLaplace arr


-- | Perform matrix relaxation for the Laplace equation,
--	using a stencil function.
--
--   Computation fn is
--	u'(i,j) = (u(i-1,j) + u(i+1,j) + u(i,j-1) + u(i,j+1)) / 4
--
relaxLaplace
	:: Array DIM2 Double
	-> Array DIM2 Double

{-# INLINE relaxLaplace #-}
relaxLaplace !arr@Manifest{}
 = traverse arr id elemFn
 where
	_ :. height :. width	
		= extent arr

	{-# INLINE elemFn #-}
	elemFn get d@(sh :. i :. j)
	 = if isBorder i j
		 then  get d
		 else (get (sh :. (i-1) :. j)
		   +   get (sh :. i     :. (j-1))
		   +   get (sh :. (i+1) :. j)
	 	   +   get (sh :. i     :. (j+1))) / 4

	-- Check if this element is on the border of the matrix.
	-- If so we can't apply the stencil because we don't have all the neighbours.
	{-# INLINE isBorder #-}
	isBorder i j
	 	=  (i == 0) || (i >= width  - 1) 
	 	|| (j == 0) || (j >= height - 1) 


-- | Apply the boundary conditions to this matrix.
--	The mask  matrix has 0 in places where boundary conditions hold
--	and 1 otherwise.
--
--	The value matrix has the boundary condition value in places where it holds,
--	and 0 otherwise.
-- 
applyBoundary
	:: Array DIM2 Double	-- ^ Boundary condition mask.
	-> Array DIM2 Double	-- ^ Boundary condition values.
	-> Array DIM2 Double	-- ^ Initial matrix.
	-> Array DIM2 Double	-- ^ Matrix with boundary conditions applied.

{-# INLINE applyBoundary #-}
applyBoundary arrBoundMask arrBoundValue arr
	= A.zipWith (+) arrBoundValue
	$ A.zipWith (*) arrBoundMask  arr


