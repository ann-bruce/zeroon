import { useCallback, useEffect, useState } from 'react'
import {
  Alert,
  Button,
  Card,
  Descriptions,
  Drawer,
  Empty,
  Input,
  List,
  Select,
  Space,
  Switch,
  Table,
  Tag,
  Timeline,
  Typography,
} from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { ReloadOutlined } from '@ant-design/icons'

type SupportCategory =
  | 'PRODUCT_PROBLEM'
  | 'SUGGESTION'
  | 'ACCOUNT_DATA_PRIVACY'
  | 'AI_RESPONSE_SAFETY'
  | 'COMPLAINT_RIGHTS'
  | 'OTHER'
type SupportStatus = 'RECEIVED' | 'IN_REVIEW' | 'WAITING_FOR_USER' | 'REPLIED' | 'CLOSED'
type EscalationCode =
  | 'ENGINEERING'
  | 'PRODUCT'
  | 'PRIVACY'
  | 'SAFETY'
  | 'COMPLAINT'
  | 'PROFESSIONAL_REVIEW'

type SupportSummary = {
  reference: string
  ownerUid: string
  category: SupportCategory
  status: SupportStatus
  subject: string
  descriptionPreview: string
  assignedAdminUid: string | null
  escalated: boolean
  escalationCode: EscalationCode | null
  createdAt: string
  updatedAt: string
}

type SupportMessage = {
  id: number
  actorType: 'USER' | 'ADMIN' | 'SYSTEM'
  visibility: 'USER_VISIBLE' | 'INTERNAL'
  actorUid: string | null
  body: string
  createdAt: string
}

type StatusHistory = {
  fromStatus: SupportStatus | null
  toStatus: SupportStatus
  actorType: 'USER' | 'ADMIN' | 'SYSTEM'
  actorUid: string | null
  reasonCode: string
  createdAt: string
}

type AuditEntry = {
  actionType: string
  actorUid: string | null
  fromValue: string | null
  toValue: string | null
  messageId: number | null
  reasonCode: string
  createdAt: string
}

type SupportDetail = Omit<SupportSummary, 'descriptionPreview'> & {
  description: string
  replyContact: string | null
  diagnostics: Record<string, unknown> | null
  messages: SupportMessage[]
  statusHistory: StatusHistory[]
  audit: AuditEntry[]
  closedAt: string | null
}

type SupportPage = {
  items: SupportSummary[]
  page: number
  size: number
  totalElements: number
}

type MutationBody = {
  category?: SupportCategory
  status?: SupportStatus
  assignToMe?: boolean
  escalated?: boolean
  escalationCode?: EscalationCode
  reasonCode: string
}

const tokenStorageKey = 'zeroon.admin.accessToken'
const categoryOptions: SupportCategory[] = [
  'PRODUCT_PROBLEM',
  'SUGGESTION',
  'ACCOUNT_DATA_PRIVACY',
  'AI_RESPONSE_SAFETY',
  'COMPLAINT_RIGHTS',
  'OTHER',
]
const statusOptions: SupportStatus[] = [
  'RECEIVED',
  'IN_REVIEW',
  'WAITING_FOR_USER',
  'REPLIED',
  'CLOSED',
]
const escalationOptions: EscalationCode[] = [
  'ENGINEERING',
  'PRODUCT',
  'PRIVACY',
  'SAFETY',
  'COMPLAINT',
  'PROFESSIONAL_REVIEW',
]

const categoryLabels: Record<SupportCategory, string> = {
  PRODUCT_PROBLEM: '产品问题',
  SUGGESTION: '意见建议',
  ACCOUNT_DATA_PRIVACY: '账户、数据与隐私',
  AI_RESPONSE_SAFETY: 'AI 回复与安全',
  COMPLAINT_RIGHTS: '投诉与权益',
  OTHER: '其他',
}

const statusLabels: Record<SupportStatus, string> = {
  RECEIVED: '已收到',
  IN_REVIEW: '处理中',
  WAITING_FOR_USER: '等待用户',
  REPLIED: '已回复',
  CLOSED: '已结束',
}

const statusColors: Record<SupportStatus, string> = {
  RECEIVED: 'blue',
  IN_REVIEW: 'processing',
  WAITING_FOR_USER: 'gold',
  REPLIED: 'cyan',
  CLOSED: 'default',
}

function formatTime(value: string) {
  return new Date(value).toLocaleString()
}

function tokenUid(token: string): string | null {
  try {
    const encoded = token.split('.')[1]
    if (!encoded) return null
    const normalized = encoded.replace(/-/g, '+').replace(/_/g, '/')
    const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=')
    const payload = JSON.parse(atob(padded)) as { uid?: unknown }
    return typeof payload.uid === 'string' ? payload.uid : null
  } catch {
    return null
  }
}

async function responseJson<T>(response: Response): Promise<T> {
  if (!response.ok) {
    let message = `请求失败：${response.status}`
    try {
      const body = (await response.json()) as { message?: string }
      if (body.message) message = body.message
    } catch {
      // The status code remains a useful fallback when no JSON error is returned.
    }
    throw new Error(message)
  }
  return (await response.json()) as T
}

export default function SupportPanel() {
  const [token, setToken] = useState(() => localStorage.getItem(tokenStorageKey) ?? '')
  const [items, setItems] = useState<SupportSummary[]>([])
  const [detail, setDetail] = useState<SupportDetail | null>(null)
  const [statusFilter, setStatusFilter] = useState<SupportStatus | undefined>()
  const [categoryFilter, setCategoryFilter] = useState<SupportCategory | undefined>()
  const [escalatedFilter, setEscalatedFilter] = useState<boolean | undefined>()
  const [loading, setLoading] = useState(false)
  const [detailLoading, setDetailLoading] = useState(false)
  const [actionLoading, setActionLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [actionError, setActionError] = useState<string | null>(null)
  const [note, setNote] = useState('')
  const [reply, setReply] = useState('')
  const [nextStatus, setNextStatus] = useState<SupportStatus | undefined>()
  const [escalationCode, setEscalationCode] = useState<EscalationCode>('ENGINEERING')

  const authHeaders = useCallback(
    () => ({
      Authorization: `Bearer ${token.trim()}`,
      'Content-Type': 'application/json',
    }),
    [token],
  )

  const loadQueue = useCallback(async () => {
    if (!token.trim()) {
      setError('请先填写后台访问令牌。')
      return
    }
    localStorage.setItem(tokenStorageKey, token.trim())
    setLoading(true)
    setError(null)
    const params = new URLSearchParams({ page: '0', size: '50' })
    if (statusFilter) params.set('status', statusFilter)
    if (categoryFilter) params.set('category', categoryFilter)
    if (escalatedFilter !== undefined) params.set('escalated', String(escalatedFilter))
    try {
      const response = await fetch(`/api/v1/admin/support-requests?${params}`, {
        headers: authHeaders(),
      })
      const data = await responseJson<SupportPage>(response)
      setItems(data.items)
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : '工单队列读取失败')
    } finally {
      setLoading(false)
    }
  }, [authHeaders, categoryFilter, escalatedFilter, statusFilter, token])

  useEffect(() => {
    if (token) void loadQueue()
    // The initial stored token should trigger one load; later filter changes are explicit.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  async function openDetail(reference: string) {
    setDetailLoading(true)
    setActionError(null)
    try {
      const response = await fetch(`/api/v1/admin/support-requests/${reference}`, {
        headers: authHeaders(),
      })
      const data = await responseJson<SupportDetail>(response)
      setDetail(data)
      setEscalationCode(data.escalationCode ?? 'ENGINEERING')
      setNextStatus(replyTransitions(data.status)[0])
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : '工单详情读取失败')
    } finally {
      setDetailLoading(false)
    }
  }

  async function mutate(body: MutationBody) {
    if (!detail) return
    setActionLoading(true)
    setActionError(null)
    try {
      const response = await fetch(`/api/v1/admin/support-requests/${detail.reference}`, {
        method: 'PATCH',
        headers: authHeaders(),
        body: JSON.stringify(body),
      })
      const data = await responseJson<SupportDetail>(response)
      setDetail(data)
      setEscalationCode(data.escalationCode ?? 'ENGINEERING')
      setNextStatus(replyTransitions(data.status)[0])
      await loadQueue()
    } catch (caught) {
      setActionError(caught instanceof Error ? caught.message : '操作失败')
    } finally {
      setActionLoading(false)
    }
  }

  async function addMessage(visibility: 'USER_VISIBLE' | 'INTERNAL') {
    if (!detail) return
    const body = visibility === 'INTERNAL' ? note : reply
    if (!body.trim()) {
      setActionError(visibility === 'INTERNAL' ? '请先填写内部备注。' : '请先填写用户回复。')
      return
    }
    if (visibility === 'USER_VISIBLE' && !nextStatus) {
      setActionError('请选择回复后的状态。')
      return
    }
    setActionLoading(true)
    setActionError(null)
    try {
      const reasonCode =
        visibility === 'INTERNAL'
          ? 'INTERNAL_CONTEXT'
          : nextStatus === 'WAITING_FOR_USER'
            ? 'CLARIFICATION_REQUESTED'
            : nextStatus === 'CLOSED'
              ? 'HANDLING_ENDED'
              : 'RESPONSE_SENT'
      const response = await fetch(
        `/api/v1/admin/support-requests/${detail.reference}/messages`,
        {
          method: 'POST',
          headers: authHeaders(),
          body: JSON.stringify({
            body: body.trim(),
            visibility,
            nextStatus: visibility === 'USER_VISIBLE' ? nextStatus : undefined,
            reasonCode,
          }),
        },
      )
      const data = await responseJson<SupportDetail>(response)
      setDetail(data)
      if (visibility === 'INTERNAL') setNote('')
      else setReply('')
      setNextStatus(replyTransitions(data.status)[0])
      await loadQueue()
    } catch (caught) {
      setActionError(caught instanceof Error ? caught.message : '消息保存失败')
    } finally {
      setActionLoading(false)
    }
  }

  const columns: ColumnsType<SupportSummary> = [
      {
        title: '状态',
        dataIndex: 'status',
        width: 104,
        render: (value: SupportStatus) => (
          <Tag color={statusColors[value]}>{statusLabels[value]}</Tag>
        ),
      },
      {
        title: '分类',
        dataIndex: 'category',
        width: 88,
        render: (value: SupportCategory) => categoryLabels[value],
      },
      {
        title: '主题',
        dataIndex: 'subject',
        render: (value: string, record) => (
          <Space direction="vertical" size={0}>
            <Typography.Text strong>{value}</Typography.Text>
            <Typography.Text type="secondary" ellipsis>
              {record.descriptionPreview}
            </Typography.Text>
          </Space>
        ),
      },
      {
        title: '处理人',
        dataIndex: 'assignedAdminUid',
        width: 128,
        render: (value: string | null) => value ?? '未分配',
      },
      {
        title: '升级',
        dataIndex: 'escalated',
        width: 112,
        render: (value: boolean, record) =>
          value ? <Tag color="volcano">{record.escalationCode}</Tag> : '—',
      },
      {
        title: '更新时间',
        dataIndex: 'updatedAt',
        width: 176,
        render: formatTime,
      },
      {
        title: '操作',
        key: 'action',
        width: 76,
        render: (_, record) => (
          <Button type="link" onClick={() => void openDetail(record.reference)}>
            处理
          </Button>
        ),
      },
    ]

  const closed = detail?.status === 'CLOSED'
  const transitions = detail ? replyTransitions(detail.status) : []
  const currentAdminUid = tokenUid(token.trim())
  const assignedToAnother =
    detail?.assignedAdminUid != null && detail.assignedAdminUid !== currentAdminUid

  return (
    <section className="panel support-panel">
      <Space direction="vertical" size="large" className="full-width">
        <div>
          <Typography.Title level={2}>用户支持</Typography.Title>
          <Typography.Paragraph>
            由人工处理用户主动提交的工单。仅查看该工单及用户选择附带的诊断信息，不访问其他
            ZEROON 私密内容。
          </Typography.Paragraph>
        </div>

        <Card>
          <Space direction="vertical" className="full-width">
            <Space.Compact className="token-input">
              <Input.Password
                aria-label="后台访问令牌"
                placeholder="粘贴后台访问令牌"
                value={token}
                onChange={(event) => setToken(event.target.value)}
              />
              <Button icon={<ReloadOutlined />} type="primary" onClick={() => void loadQueue()}>
                读取
              </Button>
            </Space.Compact>
            <Space wrap>
              <Select
                allowClear
                placeholder="全部状态"
                value={statusFilter}
                options={statusOptions.map((value) => ({ value, label: statusLabels[value] }))}
                onChange={setStatusFilter}
              />
              <Select
                allowClear
                placeholder="全部分类"
                value={categoryFilter}
                options={categoryOptions.map((value) => ({
                  value,
                  label: categoryLabels[value],
                }))}
                onChange={setCategoryFilter}
              />
              <Select
                allowClear
                placeholder="全部升级状态"
                value={escalatedFilter}
                options={[
                  { value: true, label: '已升级' },
                  { value: false, label: '未升级' },
                ]}
                onChange={setEscalatedFilter}
              />
              <Button onClick={() => void loadQueue()}>应用筛选</Button>
            </Space>
          </Space>
        </Card>

        {error ? <Alert type="warning" showIcon message={error} /> : null}
        <Table
          rowKey="reference"
          loading={loading}
          columns={columns}
          dataSource={items}
          pagination={false}
          scroll={{ x: 960 }}
        />
      </Space>

      <Drawer
        title={detail ? `工单 ${detail.reference}` : '工单详情'}
        open={detail !== null || detailLoading}
        width="min(920px, 96vw)"
        onClose={() => {
          setDetail(null)
          setActionError(null)
          setNote('')
          setReply('')
        }}
      >
        {detail ? (
          <Space direction="vertical" size="large" className="full-width">
            {actionError ? <Alert type="error" showIcon message={actionError} /> : null}

            <Descriptions bordered size="small" column={{ xs: 1, sm: 2 }}>
              <Descriptions.Item label="主题" span={2}>
                {detail.subject}
              </Descriptions.Item>
              <Descriptions.Item label="用户">{detail.ownerUid}</Descriptions.Item>
              <Descriptions.Item label="回复联系方式">
                {detail.replyContact ?? '未提供'}
              </Descriptions.Item>
              <Descriptions.Item label="状态">
                <Tag color={statusColors[detail.status]}>{statusLabels[detail.status]}</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="处理人">
                {detail.assignedAdminUid ?? '未分配'}
              </Descriptions.Item>
              <Descriptions.Item label="问题描述" span={2}>
                <Typography.Paragraph className="support-body">
                  {detail.description}
                </Typography.Paragraph>
              </Descriptions.Item>
              <Descriptions.Item label="用户选择附带的诊断信息" span={2}>
                {detail.diagnostics ? (
                  <pre className="diagnostics-content">
                    {JSON.stringify(detail.diagnostics, null, 2)}
                  </pre>
                ) : (
                  '未附带'
                )}
              </Descriptions.Item>
            </Descriptions>

            <Card title="分诊与归属" size="small">
              <Space wrap>
                {detail.status === 'RECEIVED' ? (
                  <Button
                    type="primary"
                    loading={actionLoading}
                    disabled={assignedToAnother}
                    onClick={() =>
                      void mutate({
                        assignToMe: true,
                        status: 'IN_REVIEW',
                        reasonCode: 'TRIAGE_ACCEPTED',
                      })
                    }
                  >
                    接手处理
                  </Button>
                ) : (
                  <Button
                    loading={actionLoading}
                    disabled={closed || assignedToAnother}
                    onClick={() =>
                      void mutate({
                        assignToMe: detail.assignedAdminUid === null,
                        reasonCode: 'ASSIGNMENT_UPDATED',
                      })
                    }
                  >
                    {assignedToAnother
                      ? `已由 ${detail.assignedAdminUid} 处理`
                      : detail.assignedAdminUid === null
                        ? '分配给我'
                        : '取消我的分配'}
                  </Button>
                )}
                <Select
                  value={detail.category}
                  disabled={closed || actionLoading}
                  options={categoryOptions.map((value) => ({
                    value,
                    label: categoryLabels[value],
                  }))}
                  onChange={(category) =>
                    void mutate({ category, reasonCode: 'CATEGORY_CORRECTED' })
                  }
                />
                <Space>
                  <Typography.Text>升级</Typography.Text>
                  <Switch
                    checked={detail.escalated}
                    disabled={closed || actionLoading}
                    onChange={(checked) =>
                      void mutate({
                        escalated: checked,
                        escalationCode: checked ? escalationCode : undefined,
                        reasonCode: 'ESCALATION_UPDATED',
                      })
                    }
                  />
                </Space>
                <Select
                  value={escalationCode}
                  disabled={closed || actionLoading || !detail.escalated}
                  options={escalationOptions.map((value) => ({ value, label: value }))}
                  onChange={(value) => {
                    setEscalationCode(value)
                    void mutate({
                      escalated: true,
                      escalationCode: value,
                      reasonCode: 'ESCALATION_UPDATED',
                    })
                  }}
                />
              </Space>
            </Card>

            <Card title="沟通记录" size="small">
              {detail.messages.length ? (
                <List
                  dataSource={detail.messages}
                  renderItem={(message) => (
                    <List.Item>
                      <div
                        className={
                          message.visibility === 'INTERNAL'
                            ? 'support-message internal'
                            : 'support-message'
                        }
                      >
                        <Space wrap>
                          <Tag color={message.visibility === 'INTERNAL' ? 'orange' : 'green'}>
                            {message.visibility === 'INTERNAL' ? '仅内部可见' : '用户可见'}
                          </Tag>
                          <Typography.Text type="secondary">
                            {message.actorType} · {message.actorUid ?? '已删除账号'} ·{' '}
                            {formatTime(message.createdAt)}
                          </Typography.Text>
                        </Space>
                        <Typography.Paragraph className="support-body">
                          {message.body}
                        </Typography.Paragraph>
                      </div>
                    </List.Item>
                  )}
                />
              ) : (
                <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description="暂无沟通记录" />
              )}
            </Card>

            <Card title="回复用户（用户可见）" size="small">
              <Space direction="vertical" className="full-width">
                <Alert
                  type="info"
                  showIcon
                  message="这是人工支持回复；发送内容会立即对用户可见，并同步更新工单状态。"
                />
                <Input.TextArea
                  rows={5}
                  value={reply}
                  disabled={closed || transitions.length === 0}
                  placeholder={closed ? '工单已结束，不能继续回复。' : '填写清晰、坦诚的人工回复'}
                  onChange={(event) => setReply(event.target.value)}
                />
                <Space wrap>
                  <Select
                    value={nextStatus}
                    disabled={closed || transitions.length === 0}
                    placeholder="回复后状态"
                    options={transitions.map((value) => ({
                      value,
                      label: statusLabels[value],
                    }))}
                    onChange={setNextStatus}
                  />
                  <Button
                    type="primary"
                    loading={actionLoading}
                    disabled={closed || transitions.length === 0}
                    onClick={() => void addMessage('USER_VISIBLE')}
                  >
                    发送人工回复
                  </Button>
                </Space>
              </Space>
            </Card>

            <Card title="内部备注（用户不可见）" size="small">
              <Space direction="vertical" className="full-width">
                <Alert
                  type="warning"
                  showIcon
                  message="内部备注只用于处理上下文，不会出现在用户端，也不会改变工单状态。"
                />
                <Input.TextArea
                  rows={4}
                  value={note}
                  disabled={closed}
                  placeholder={closed ? '工单已结束，不能添加备注。' : '填写内部处理上下文'}
                  onChange={(event) => setNote(event.target.value)}
                />
                <Button
                  loading={actionLoading}
                  disabled={closed}
                  onClick={() => void addMessage('INTERNAL')}
                >
                  保存内部备注
                </Button>
              </Space>
            </Card>

            <Card title="状态历史" size="small">
              <Timeline
                items={detail.statusHistory.map((entry) => ({
                  children: `${entry.fromStatus ?? '创建'} → ${statusLabels[entry.toStatus]} · ${
                    entry.actorType
                  } · ${entry.reasonCode} · ${formatTime(entry.createdAt)}`,
                }))}
              />
            </Card>

            <Card title="操作审计（不复制正文）" size="small">
              <Timeline
                items={detail.audit.map((entry) => ({
                  children: `${entry.actionType} · ${entry.fromValue ?? '—'} → ${
                    entry.toValue ?? '—'
                  } · ${entry.actorUid ?? '已删除账号'} · ${entry.reasonCode} · ${formatTime(
                    entry.createdAt,
                  )}`,
                }))}
              />
            </Card>
          </Space>
        ) : (
          <Typography.Text>正在读取详情...</Typography.Text>
        )}
      </Drawer>
    </section>
  )
}

function replyTransitions(status: SupportStatus): SupportStatus[] {
  switch (status) {
    case 'RECEIVED':
      return ['CLOSED']
    case 'IN_REVIEW':
      return ['WAITING_FOR_USER', 'REPLIED', 'CLOSED']
    case 'WAITING_FOR_USER':
    case 'REPLIED':
      return ['CLOSED']
    case 'CLOSED':
      return []
  }
}
