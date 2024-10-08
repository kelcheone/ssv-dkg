package testing

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bloxapp/ssv-dkg/pkgs/wire"
	"github.com/bloxapp/ssv-dkg/spec"
	"github.com/bloxapp/ssv-dkg/spec/testing/fixtures"
)

func TestValidateInitMessage(t *testing.T) {
	t.Run("valid", func(t *testing.T) {
		require.NoError(t, spec.ValidateInitMessage(&wire.Init{
			Operators:             fixtures.GenerateOperators(4),
			T:                     3,
			WithdrawalCredentials: fixtures.TestWithdrawalCred,
			Fork:                  fixtures.TestFork,
			Owner:                 fixtures.TestOwnerAddress,
			Nonce:                 0,
		}))
	})

	t.Run("disordered operators", func(t *testing.T) {
		require.EqualError(t, spec.ValidateInitMessage(&wire.Init{
			Operators: []*wire.Operator{
				fixtures.GenerateOperators(4)[0],
				fixtures.GenerateOperators(4)[1],
				fixtures.GenerateOperators(4)[3],
				fixtures.GenerateOperators(4)[2],
			},
			T:                     3,
			WithdrawalCredentials: fixtures.TestWithdrawalCred,
			Fork:                  fixtures.TestFork,
			Owner:                 fixtures.TestOwnerAddress,
			Nonce:                 0,
		}), "operators not unique or not ordered")
	})
	t.Run("non unique operators", func(t *testing.T) {
		require.EqualError(t, spec.ValidateInitMessage(&wire.Init{
			Operators: []*wire.Operator{
				fixtures.GenerateOperators(4)[0],
				fixtures.GenerateOperators(4)[1],
				fixtures.GenerateOperators(4)[2],
				fixtures.GenerateOperators(4)[2],
			},
			T:                     3,
			WithdrawalCredentials: fixtures.TestWithdrawalCred,
			Fork:                  fixtures.TestFork,
			Owner:                 fixtures.TestOwnerAddress,
			Nonce:                 0,
		}), "operators not unique or not ordered")
	})
	t.Run("no operators", func(t *testing.T) {
		require.EqualError(t, spec.ValidateInitMessage(&wire.Init{
			Operators:             []*wire.Operator{},
			T:                     3,
			WithdrawalCredentials: fixtures.TestWithdrawalCred,
			Fork:                  fixtures.TestFork,
			Owner:                 fixtures.TestOwnerAddress,
			Nonce:                 0,
		}), "threshold set is invalid")
	})
	t.Run("nil operators", func(t *testing.T) {
		require.EqualError(t, spec.ValidateInitMessage(&wire.Init{
			Operators:             nil,
			T:                     3,
			WithdrawalCredentials: fixtures.TestWithdrawalCred,
			Fork:                  fixtures.TestFork,
			Owner:                 fixtures.TestOwnerAddress,
			Nonce:                 0,
		}), "threshold set is invalid")
	})
	t.Run("non 3f+1 operators", func(t *testing.T) {
		require.EqualError(t, spec.ValidateInitMessage(&wire.Init{
			Operators: []*wire.Operator{
				fixtures.GenerateOperators(4)[0],
				fixtures.GenerateOperators(4)[1],
				fixtures.GenerateOperators(4)[2],
			},
			T:                     3,
			WithdrawalCredentials: fixtures.TestWithdrawalCred,
			Fork:                  fixtures.TestFork,
			Owner:                 fixtures.TestOwnerAddress,
			Nonce:                 0,
		}), "threshold set is invalid")
	})
	t.Run("non 3f+1 operators", func(t *testing.T) {
		require.EqualError(t, spec.ValidateInitMessage(&wire.Init{
			Operators: []*wire.Operator{
				fixtures.GenerateOperators(7)[0],
				fixtures.GenerateOperators(7)[1],
				fixtures.GenerateOperators(7)[2],
				fixtures.GenerateOperators(7)[3],
				fixtures.GenerateOperators(7)[4],
			},
			T:                     3,
			WithdrawalCredentials: fixtures.TestWithdrawalCred,
			Fork:                  fixtures.TestFork,
			Owner:                 fixtures.TestOwnerAddress,
			Nonce:                 0,
		}), "threshold set is invalid")
	})
	t.Run("non 2f+1 threshold", func(t *testing.T) {
		require.EqualError(t, spec.ValidateInitMessage(&wire.Init{
			Operators:             fixtures.GenerateOperators(4),
			T:                     2,
			WithdrawalCredentials: fixtures.TestWithdrawalCred,
			Fork:                  fixtures.TestFork,
			Owner:                 fixtures.TestOwnerAddress,
			Nonce:                 0,
		}), "threshold set is invalid")
	})
}
