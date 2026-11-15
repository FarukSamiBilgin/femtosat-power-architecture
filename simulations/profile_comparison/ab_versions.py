import numpy as np, matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt

SIGMA=5.670e-8; SOLAR=1361.0; DAY=86400.0
def eta_teg(ZT,Th=475,Tc=218,beta=0.58):
    M=np.sqrt(1+ZT); return beta*(Th-Tc)/Th*(M-1)/(M+Tc/Th)

# ---- common platform ----
A_sail=4.0; rho=0.4; m_sail=rho*A_sail; m_chip=0.30; m_base=m_sail+m_chip
def vfrac(m_extra): return 0.200*m_base/(m_base+m_extra)
A_pv=9e-4; eta_pv=0.18
def P_pv(d): return eta_pv*A_pv*SOLAR/d**2*1e3   # mW
E_comms=44.6e-3  # J bucket
loads={'sleep':0.10,'min':0.41,'nav':0.82,'data':6.55,'comms':22.3,'peak':29.1}

print("="*70)
print("VERSION A — MASS-OPTIMAL (no thermal RTG)")
print("="*70)
mA=0.03  # betavoltaic keep-alive
print(f"Mass: base {m_base:.2f} + betavoltaic {mA:.2f} = {m_base+mA:.2f} g")
print(f"Velocity {vfrac(mA):.3f}c  ->  transit {4.37/vfrac(mA):.0f} yr")
P_beta=3e-6  # W keep-alive
print(f"\nKeep-alive (betavoltaic) ~{P_beta*1e6:.0f} uW  (RTC+SRAM+wake timer)")
print("Power by phase:")
print(f"  Launch/push 1 AU : PV {P_pv(1):.0f} mW  (+laser-push: thermal survival, storage->FULL)")
print(f"  Near-Sun 3 AU    : PV {P_pv(3):.1f} mW   -> bank + early science")
print(f"  Near-Sun 5 AU    : PV {P_pv(5):.1f} mW    -> crossover, science winds down")
print(f"  DEEP CRUISE 20yr : betavoltaic {P_beta*1e6:.0f} uW only -> DORMANT, ultra-low-duty")
print(f"  Flyby (new star) : PV {P_pv(1):.0f} mW  -> cold-start, burst science+comms")
# ultra-low-duty sampling capability in cruise
E_day=P_beta*DAY
print(f"\nCruise sampling: betavoltaic banks {E_day*1e3:.2f} mJ/day -> ~{E_day/0.005:.0f} sensor reads/day (5mJ each)")
# storage: bursts only when PV active; battery NOT relied on for 20yr retention
V_hi,V_lo=4.2,3.6
C=2*(loads['peak']*1e-3*2/0.9)/(V_hi**2-V_lo**2)
print(f"Storage: supercap {C*1e3:.0f} mF (bursts) + small batt (near-Sun/flyby only)")
print("  -> 20yr charge-retention NOT required (PV cold-start at flyby) = reliability WIN")

print("\n"+"="*70)
print("VERSION B — CONTINUOUS SCIENCE (Pu-238 150 mg RTG)")
print("="*70)
mB=0.75
print(f"Mass: base {m_base:.2f} + RTG {mB:.2f} = {m_base+mB:.2f} g")
print(f"Velocity {vfrac(mB):.3f}c  ->  transit {4.37/vfrac(mB):.0f} yr   ({(1-vfrac(mB)/vfrac(mA))*100:.0f}% slower than A)")
Qth=0.150*0.54
Prtg=eta_teg(0.7)*Qth*1e3; Ptot=eta_teg(1.25)*Qth*1e3; Pte=Ptot-Prtg
print(f"\nRTG {Prtg:.2f} mW + TE-reject harvest {Pte:.2f} mW = {Ptot:.2f} mW (CONTINUOUS, all phases)")
decay=np.exp(-np.log(2)*20/87.7)
print(f"  EoL(20yr): {Ptot*decay:.2f} mW  (Pu-238 decay {decay:.2f})")
src_dc=Ptot*0.88
print("Power by phase:")
print(f"  Near-Sun 1 AU    : PV {P_pv(1):.0f} + RTG/TE {Ptot:.1f} = {P_pv(1)+Ptot:.0f} mW")
print(f"  DEEP CRUISE 20yr : RTG/TE {src_dc:.2f} mW (x{src_dc/0.10:.0f} sleep margin) -> CONTINUOUS ops")
print(f"  comms refill deep cruise: {E_comms/(src_dc*0.95*1e-3):.1f} s")
print(f"  Flyby            : PV {P_pv(1):.0f} + RTG/TE {Ptot:.1f} mW")
print("Bonus: RTG waste heat keeps electronics/battery warm in deep space")
print("Storage: supercap + battery CYCLED continuously 20-30yr (solid-state, reliability concern)")
print("Control: phase FSM + scheduled PID (NOT 4-controller AI bank)")

# ---------- comparison figure ----------
fig,(ax1,ax2)=plt.subplots(1,2,figsize=(13,5))
# left: velocity vs added mass
mm=np.linspace(0,4.5,200); vv=np.array([vfrac(x) for x in mm])
ax1.plot(mm,vv,'k',lw=2)
for label,mx,col in [('A: no RTG',mA,'g'),('B: Pu-238',mB,'b'),('Am-241(elenen)',4.2,'r')]:
    ax1.plot(mx,vfrac(mx),'o',color=col,ms=10); ax1.annotate(f'{label}\n{vfrac(mx):.3f}c',(mx,vfrac(mx)),textcoords='offset points',xytext=(8,5),fontsize=9,color=col)
ax1.set_xlabel('Eklenen kütle (RTG/betavoltaik) [g]'); ax1.set_ylabel('Son hız [c]')
ax1.set_title('Kütle → Hız cezası'); ax1.grid(alpha=.3)
# right: source power vs distance, both versions
d=np.logspace(0,3.6,300)
pv=eta_pv*A_pv*SOLAR/d**2*1e3
ax2.loglog(d,pv,'orange',lw=2,label='PV (her iki versiyon)')
ax2.loglog(d,np.full_like(d,Ptot),'b--',lw=2,label=f'B: RTG+TE {Ptot:.1f} mW (sürekli)')
ax2.loglog(d,np.full_like(d,P_beta*1e6/1000),'g:',lw=2,label=f'A: betavoltaik {P_beta*1e6:.0f} µW (dormant)')
ax2.axhline(0.10,color='gray',ls='-.',lw=1,label='uyku 0.10 mW')
ax2.set_xlabel('Yıldızdan uzaklık [AU]'); ax2.set_ylabel('Kaynak gücü [mW]')
ax2.set_title('Derin uzayda fark: B sürekli ~6 mW, A ~µW dormant')
ax2.set_ylim(1e-4,1e3); ax2.grid(True,which='both',alpha=.3); ax2.legend(fontsize=8)
plt.tight_layout(); plt.savefig('/home/claude/AB_comparison.png',dpi=130)
print("\nfigure saved")
