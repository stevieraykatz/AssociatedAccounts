export const associationsStoreAbi = [
  {
    "type": "function",
    "name": "areAccountsAssociated",
    "inputs": [
      {
        "name": "account1",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "account2",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getActiveAssociationsForAccount",
    "inputs": [
      {
        "name": "account",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple[]",
        "internalType": "struct AssociatedAccounts.SignedAssociationRecord[]",
        "components": [
          {
            "name": "validAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "revokedAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "initiatorCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "approverCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "initiatorSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "approverSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "record",
            "type": "tuple",
            "internalType": "struct AssociatedAccounts.AssociatedAccountRecord",
            "components": [
              {
                "name": "initiator",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "approver",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "interfaceId",
                "type": "bytes4",
                "internalType": "bytes4"
              },
              {
                "name": "data",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getAssociation",
    "inputs": [
      {
        "name": "uuid",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple",
        "internalType": "struct AssociatedAccounts.SignedAssociationRecord",
        "components": [
          {
            "name": "validAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "revokedAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "initiatorCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "approverCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "initiatorSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "approverSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "record",
            "type": "tuple",
            "internalType": "struct AssociatedAccounts.AssociatedAccountRecord",
            "components": [
              {
                "name": "initiator",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "approver",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "interfaceId",
                "type": "bytes4",
                "internalType": "bytes4"
              },
              {
                "name": "data",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getAssociationBetweenAccounts",
    "inputs": [
      {
        "name": "account1",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "account2",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "exists",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "sar",
        "type": "tuple",
        "internalType": "struct AssociatedAccounts.SignedAssociationRecord",
        "components": [
          {
            "name": "validAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "revokedAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "initiatorCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "approverCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "initiatorSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "approverSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "record",
            "type": "tuple",
            "internalType": "struct AssociatedAccounts.AssociatedAccountRecord",
            "components": [
              {
                "name": "initiator",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "approver",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "interfaceId",
                "type": "bytes4",
                "internalType": "bytes4"
              },
              {
                "name": "data",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getAssociationUuidsForAccount",
    "inputs": [
      {
        "name": "account",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getAssociationsForAccount",
    "inputs": [
      {
        "name": "account",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple[]",
        "internalType": "struct AssociatedAccounts.SignedAssociationRecord[]",
        "components": [
          {
            "name": "validAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "revokedAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "initiatorCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "approverCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "initiatorSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "approverSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "record",
            "type": "tuple",
            "internalType": "struct AssociatedAccounts.AssociatedAccountRecord",
            "components": [
              {
                "name": "initiator",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "approver",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "interfaceId",
                "type": "bytes4",
                "internalType": "bytes4"
              },
              {
                "name": "data",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "revokeAssociation",
    "inputs": [
      {
        "name": "uuid",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "revokedAt",
        "type": "uint120",
        "internalType": "uint120"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "storeAssociation",
    "inputs": [
      {
        "name": "sar",
        "type": "tuple",
        "internalType": "struct AssociatedAccounts.SignedAssociationRecord",
        "components": [
          {
            "name": "validAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "revokedAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "initiatorCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "approverCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "initiatorSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "approverSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "record",
            "type": "tuple",
            "internalType": "struct AssociatedAccounts.AssociatedAccountRecord",
            "components": [
              {
                "name": "initiator",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "approver",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "interfaceId",
                "type": "bytes4",
                "internalType": "bytes4"
              },
              {
                "name": "data",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "AssociationCreated",
    "inputs": [
      {
        "name": "uuid",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "initiator",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "approver",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "sar",
        "type": "tuple",
        "indexed": false,
        "internalType": "struct AssociatedAccounts.SignedAssociationRecord",
        "components": [
          {
            "name": "validAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "revokedAt",
            "type": "uint120",
            "internalType": "uint120"
          },
          {
            "name": "initiatorCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "approverCurve",
            "type": "bytes2",
            "internalType": "bytes2"
          },
          {
            "name": "initiatorSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "approverSignature",
            "type": "bytes",
            "internalType": "bytes"
          },
          {
            "name": "record",
            "type": "tuple",
            "internalType": "struct AssociatedAccounts.AssociatedAccountRecord",
            "components": [
              {
                "name": "initiator",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "approver",
                "type": "bytes",
                "internalType": "bytes"
              },
              {
                "name": "interfaceId",
                "type": "bytes4",
                "internalType": "bytes4"
              },
              {
                "name": "data",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "AssociationRevoked",
    "inputs": [
      {
        "name": "uuid",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "revoker",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "AssociationAlreadyExists",
    "inputs": []
  },
  {
    "type": "error",
    "name": "AssociationAlreadyRevoked",
    "inputs": []
  },
  {
    "type": "error",
    "name": "AssociationNotFound",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InteroperableAddressParsingError",
    "inputs": [
      {
        "name": "",
        "type": "bytes",
        "internalType": "bytes"
      }
    ]
  },
  {
    "type": "error",
    "name": "InvalidAssociation",
    "inputs": []
  },
  {
    "type": "error",
    "name": "UnauthorizedRevocation",
    "inputs": []
  },
  {
    "type": "error",
    "name": "UnsupportedChainType",
    "inputs": [
      {
        "name": "chainType",
        "type": "bytes2",
        "internalType": "bytes2"
      }
    ]
  },
  {
    "type": "error",
    "name": "UnsupportedCurve",
    "inputs": [
      {
        "name": "curve",
        "type": "bytes2",
        "internalType": "bytes2"
      }
    ]
  }
] as const;
