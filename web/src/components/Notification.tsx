import React from "react";
import {cn} from "@/lib/utils";
import {Button} from "@/components/ui/button";
import Image from "@/components/ui/Image"
import { useComponentValue, useEntityQuery } from '@dojoengine/react'
import { useDojo } from '@/DojoContext'
import { EntityIndex, HasValue } from '@latticexyz/recs'
import { felt252ToString } from '@/global/utils'

const Notif: React.FC<{ entityIndex: EntityIndex }> = ({ entityIndex }) => {
  const {
    setup: {
      components: { PixelType },
    },
  } = useDojo()

  const pixelType = useComponentValue(PixelType, entityIndex)
  const name = felt252ToString(pixelType?.name ?? 'Unknown')

  // TODO: add focus on Notif click...coordinates is inside pixelType

  return (
    <div
      className={cn(
        [
          'flex items-center'
        ])}
    >
      <div className={cn(['w-[20px] grow-0'])}>
        <div className={cn(['h-2 w-2 rounded-full bg-brand-danger'])}/>
      </div>
      <div className={cn(['grow'])}>
        <h2 className={cn(['text-white text-left text-sm font-semibold'])}>{name} pixel needs your attention</h2>
      </div>
      <Button
        variant={'icon'}
        size={'icon'}
        className={cn(['w-[20px] grow-0 font-emoji text-xl text-brand-skyblue'])}
      >
        &#x1f50d;
      </Button>
    </div>
  )
}

export default function Notification() {
    const [isOpen, setIsOpen] = React.useState<boolean>(false)

  const {
    setup: {
      components: { NeedsAttention, Owner },
    },
    account: { account }
  } = useDojo()

  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  const notifs = useEntityQuery([HasValue(NeedsAttention, { value: true }), HasValue(Owner, { address: account.address })])

    return (
        <>
            <Button
                variant={'notification'}
                size={'notification'}
                className={cn(
                    [
                        'fixed left-0 z-40',
                        'font-emoji text-[28px]'
                    ])}
                onClick={() => setIsOpen(true)}
            >
                <span className={cn(['relative'])}>
                    &#x1F514;
                    <div
                        className={cn(['absolute top-[9px] right-[5px] border h-2 w-2 rounded-full bg-brand-danger'])}/>
                </span>
            </Button>

            <div
                className={cn(
                    [
                        'fixed bottom-0 z-50',
                        'h-[calc(100vh-var(--header-height))] w-[237px]',
                        'bg-brand-violet border-r-[1px] border-black',
                        'py-sm pr-sm pl-xs',
                        'transform transition-transform duration-300',
                        '-translate-x-full',
                        {'translate-x-0': isOpen}
                    ])}
            >
                <div
                    className={cn(
                        [
                            'h-full',
                            'flex flex-col gap-y-sm'
                        ])}
                >
                    <div
                        className={cn(
                            [
                                'flex items-center'
                            ])}
                    >
                        <div className={cn(['w-[20px] grow-0'])}></div>
                        <div className={cn(['grow py-xs'])}>
                            <h2 className={cn(['text-brand-violetAccent text-left text-base uppercase font-silkscreen'])}>Notifications</h2>
                        </div>
                        <Button
                            variant={'icon'}
                            size={'icon'}
                            className={cn(['w-[20px] grow-0'])}
                            onClick={() => setIsOpen(false)}
                        >
                            <Image src={'/assets/svg/icon_chevron_left.svg'} alt={'Arrow Left Icon'}/>
                        </Button>
                    </div>

                    {notifs.map(notif => (
                      <Notif entityIndex={notif} key={notif} />
                    ))}



                </div>
            </div>
        </>
    )
}
