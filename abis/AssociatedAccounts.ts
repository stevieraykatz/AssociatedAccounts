export const associatedAccountsAbi = [
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
  }
] as const;
