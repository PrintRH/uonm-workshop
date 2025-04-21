"use client";

import React, { useState } from "react";
import { formatEther } from "viem";
import { IntegerInput } from "~~/components/scaffold-eth";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

const BrokerPage = () => {
  const [amountValue, setAmountValue] = useState<string | bigint>("");
  const { writeContractAsync: writeUonmBrokerAsync } = useScaffoldWriteContract({ contractName: "UoNMBroker" });

  const { data: uonmTokenBalance } = useScaffoldReadContract({
    contractName: "UoNMBroker",
    functionName: "getUonmTokenBalance",
  });

  return (
    <div style={{ display: "flex", justifyContent: "center", marginTop: "10rem" }}>
      <div className="card bg-base-100 w-96 shadow-xl border border-[#05DFF9]">
        <div className="card-body">
          <h2 className="card-title justify-center">UoNM Token Broker</h2>
          <IntegerInput
            value={amountValue.toString()}
            onChange={updatedValue => {
              setAmountValue(updatedValue);
            }}
            placeholder="Enter amount in ETH and hit (*)"
          />
          <span className="text-sm text-center -mt-2">
            UoNM Broker Balance: {uonmTokenBalance !== undefined ? formatEther(uonmTokenBalance) : "Loading..."}{" "}
            Tokens{" "}
          </span>
          <button
            className="btn btn-primary"
            onClick={async () => {
              try {
                await writeUonmBrokerAsync({
                  functionName: "buyUonmTokens",
                  value: typeof amountValue === "string" ? BigInt(amountValue) : amountValue,
                });
              } catch (e) {
                console.error("Error setting greeting:", e);
              }
            }}
          >
            Buy UoNM Tokens
          </button>
        </div>
      </div>
    </div>
  );
};

export default BrokerPage;
